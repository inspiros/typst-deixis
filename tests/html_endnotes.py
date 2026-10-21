#!/usr/bin/env python3
"""Compile and inspect the HTML endnote regression, without browser dependencies."""

import argparse
from collections import Counter
from html.parser import HTMLParser
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
# Embedded Deixis notes currently exceed Typst's HTML layout-pass budget. Keep
# their reproducer opt-in and strict, rather than accepting convergence warnings.
CASES = ("report", "series", "references", "page", "custom", "custom-native", "chicago", "native-nested")
VOID = frozenset("area base br col embed hr img input link meta param source track wbr".split())


class Element:
    def __init__(self, tag, attrs=(), parent=None, start=0):
        self.tag, self.attrs, self.parent = tag, dict(attrs), parent
        self.children, self.start, self.end = [], start, start

    def text(self):
        return "".join(child.text() if isinstance(child, Element) else child for child in self.children)

    def descendants(self):
        for child in self.children:
            if isinstance(child, Element):
                yield child
                yield from child.descendants()

    def ancestors(self):
        node = self.parent
        while node is not None:
            yield node
            node = node.parent


class Document(HTMLParser):
    def __init__(self, source):
        super().__init__(convert_charrefs=True)
        self.root = Element("root")
        self.stack = [self.root]
        self.text_offset = 0
        self.feed(source)
        self.close()
        assert len(self.stack) == 1, "Unclosed HTML elements"
        self.elements = list(self.root.descendants())

    def handle_starttag(self, tag, attrs):
        node = Element(tag, attrs, self.stack[-1], self.text_offset)
        self.stack[-1].children.append(node)
        if tag not in VOID:
            self.stack.append(node)

    def handle_startendtag(self, tag, attrs):
        self.handle_starttag(tag, attrs)
        if tag not in VOID:
            self.handle_endtag(tag)

    def handle_endtag(self, tag):
        if tag in VOID:
            return
        assert len(self.stack) > 1 and self.stack[-1].tag == tag, f"Unexpected closing tag: {tag}"
        self.stack.pop().end = self.text_offset

    def handle_data(self, data):
        self.stack[-1].children.append(data)
        self.text_offset += len(data)


def check_html(page, case, backlinks="default"):
    doc = Document(page)
    ids = Counter(node.attrs["id"] for node in doc.elements if "id" in node.attrs)
    anchors = [node for node in doc.elements if node.tag == "a"]
    links = [node.attrs["href"][1:] for node in anchors if node.attrs.get("href", "").startswith("#")]
    assert links and all(ids[target] == 1 for target in links), (ids, links)
    assert all(count == 1 for count in ids.values()), ids
    marks = {key.removeprefix("deixis-mark-") for key in ids if key.startswith("deixis-mark-")}
    bodies = {key.removeprefix("deixis-body-") for key in ids if key.startswith("deixis-body-")}
    expected_count = {"report": 2, "series": 4, "nested": 3, "references": 1,
                      "page": 2, "custom": 1, "custom-native": 1, "chicago": 1, "native-nested": 1}[case]
    assert marks == bodies and len(marks) == expected_count, (marks, bodies)
    for uid in marks:
        mark_id, body_id = "deixis-mark-" + uid, "deixis-body-" + uid
        assert body_id in links, ("Missing mark-to-body link", uid)
        mark = next(node for node in doc.elements if node.attrs.get("id") == mark_id)
        following = mark.parent.children[mark.parent.children.index(mark) + 1:]
        next_element = next((node for node in following if isinstance(node, Element)), None)
        assert next_element is not None and next_element.tag == "a" and next_element.attrs.get("href") == "#" + body_id, (
            "In-text marker is not linked to its body", uid)
        body = next(node for node in doc.elements if node.attrs.get("id") == body_id)
        item = body
        while item is not None and item.tag != "li":
            item = item.parent
        assert item is not None, ("Body outside semantic list", uid)
        assert any(node.tag == "a" and node.attrs.get("href") == "#" + mark_id
                   for node in item.descendants()), ("Missing body-to-mark link", uid)
        if backlinks == "true":
            assert sum(node.tag == "a" and node.attrs.get("href") == "#" + mark_id
                       for node in item.descendants()) >= 2, ("Missing extra backlink button", uid)

    lists = [node for node in doc.elements if node.tag == "ol"
             and "deixis-notes" in node.attrs.get("class", "").split()
             and not any(parent.tag == "aside" for parent in node.ancestors())]
    expected = {
        "report": [("Printer", ("world", "text"))],
        "series": [("Alpha", ("Alpha First.", "Alpha Second.")),
                   ("Beta", ("Beta First.", "Beta Second."))],
        "nested": [("Printer", ("Outer Body.",))],
        "references": [("Printer", ("Named Body.",))],
        "page": [("Printer", ("Page First.", "Page Second."))],
        "custom": [("Printer", ("Custom Body.",))],
        "custom-native": [("Printer", ("Custom Body.",))],
        "chicago": [("Printer", ("Chicago Body.",))],
        "native-nested": [("Printer", ("Outer Body.",))],
    }[case]
    assert len(lists) == len(expected), len(lists)
    text = doc.root.text()
    for node, (sentinel, snippets) in zip(lists, expected):
        before, after = "Before " + sentinel + ".", "After " + sentinel + "."
        assert text.count(before) == text.count(after) == 1, (before, after)
        assert text.index(before) + len(before) <= node.start <= node.end <= text.index(after), sentinel
        items = [child for child in node.children if isinstance(child, Element) and child.tag == "li"]
        assert len(items) == len(snippets), (sentinel, len(items))
        for item, snippet in zip(items, snippets):
            assert text.count(snippet) == 1 and snippet in item.text(), snippet
    if case == "nested":
        for snippet in ("Nested Footnote Body.", "Nested Margin Body."):
            assert text.count(snippet) == 1, snippet
    if case == "references":
        assert links.count("deixis-body-id-named") >= 3, links
    if case == "page":
        markers = [node.text() for node in anchors
                   if node.attrs.get("href", "").startswith("#deixis-body-")]
        assert markers == ["1", "2"], markers
    if case == "native-nested":
        assert text.count("Native Nested Footnote Body.") == 1, text
    if case in ("custom", "custom-native"):
        assert text.count("Custom Prefix.") == 1, text


def check_html_endnotes(base, source, out, cases=CASES):
    """Runner entry point; base includes the compiler, root and package path."""
    out = Path(out)
    out.mkdir(parents=True, exist_ok=True)
    for case in cases:
        for backlinks in ("default", "true"):
            stem = f"html-endnotes-{case}-{backlinks}"
            target = out / (stem + ".html")
            command = [str(base[0]), "compile", *map(str, base[1:]),
                       "--features", "html", "--format", "html",
                       "--input", "case=" + case, "--input", "backlinks=" + backlinks,
                       str(source), str(target)]
            result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True, timeout=120)
            (out / (stem + ".log")).write_text(result.stdout + result.stderr)
            diagnostics = re.findall(r"^(?:warning|error):.*$", result.stderr, flags=re.M)
            assert result.returncode == 0 and diagnostics == [
                "warning: html export is under active development and incomplete"], result.stderr
            check_html(target.read_text(), case, backlinks)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--typst", default="typst")
    parser.add_argument("--package-path", type=Path, default=ROOT / "target/html-issue/pkg/typst/packages")
    parser.add_argument("--output", type=Path, default=ROOT / "target/html-issue/checks")
    parser.add_argument("--case", action="append", choices=(*CASES, "nested"),
                        help="Select a case (repeatable); nested is a known failing strict probe.")
    args = parser.parse_args()
    check_html_endnotes([args.typst, "--root", str(ROOT), "--package-path", str(args.package_path)],
                        ROOT / "tests/integration/html-endnotes.typ", args.output, cases=args.case or CASES)
    print(f"PASS HTML endnotes ({len(args.case or CASES)} cases, default and explicit backlinks)")


if __name__ == "__main__":
    main()
