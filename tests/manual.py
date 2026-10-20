#!/usr/bin/env python3
"""Check compact manual coverage, defaults, navigation and physical text bounds."""
import argparse
from collections import Counter
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET

from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--typst', default='typst')
    parser.add_argument('--pdf', type=Path, help='Use an already-built manual PDF.')
    parser.add_argument('--input', action='append', default=[], help='Manual build/evaluation input, e.g. paper=us-letter.')
    parser.add_argument('--output', type=Path, default=ROOT / 'target/manual-check')
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    subprocess.run([sys.executable, str(ROOT / 'scripts/render-manual-examples.py'), '--check'],
                   check=True, capture_output=True, text=True)
    flags = [arg for value in args.input for arg in ('--input', value)]

    def typst(command, *rest):
        result = subprocess.run([args.typst, command, '--root', str(ROOT), *flags, *map(str, rest)],
                                text=True, capture_output=True, timeout=120, cwd=ROOT)
        assert result.returncode == 0 and not result.stderr, result.stderr
        return result.stdout

    model = json.loads(typst('eval', '--format', 'json', '''{
      import "/docs/reference/catalog.typ" as api
      (exports: api.exports, groups: api.groups,
       parameter_docs: ("deixis-connect", "deixis-route", "deixis-prepare-connector",
         "deixis-arrowhead", "deixis-render-head", "deixis-render-connector",
         "deixis-routing-scene", "deixis-route-group", "deixis-routing",
         "deixis-query-notes", "deixis-generate-body-meta",
         "deixis-generate-body-marker", "deixis-generate-body-content",
         "deixis-generate-backlinks").map(name => (
           name: name, args: api.function(name).args.values()
         )),
       selected: api.groups.map(g => g.entries.map(e => (
         names: e.names, args: e.args.map(name => (
           name: name, default: api.default(e.names.first(), name)
         ))))).flatten())
    }'''))
    exports = model['exports']
    names = [n for g in model['groups'] for e in g['entries'] for n in e['names']]
    assert Counter(names) == Counter(exports)
    assert len(names) == len(set(names))
    for entry in model['parameter_docs']:
        assert all(a['description'].strip() and a.get('types') for a in entry['args']), entry['name']
    # Catch accidental source-copy drift in three distinct default contracts.
    defaults = {e['names'][0]: {a['name']: a['default'] for a in e['args']} for e in model['selected']}
    assert defaults['deixis-arrowhead']['shape'] == '"stealth"'
    assert defaults['deixis-sidenote']['side'] == '"outside"'
    assert defaults['deixis-setup-notes']['page-overlays'] == 'true'
    for group in model['groups']:
        assert (ROOT / 'docs/guides' / group['guide']).is_file()
        for entry in group['entries']:
            assert entry['setup'] in ('setup', 'free', 'conditional', 'installs')
            if 'guide' in entry:
                assert (ROOT / 'docs/guides' / entry['guide']).is_file()
    pdf = args.pdf or args.output / 'manual.pdf'
    if args.pdf is None:
        typst('compile', ROOT / 'docs/manual.typ', pdf)
    records = json.loads(typst('eval', '--in', ROOT / 'docs/manual.typ', '--format', 'json',
                               'query(<manual-api>).map(m => (name: m.value, page: m.location().page()))'))
    assert Counter(r['name'] for r in records) == Counter(exports)
    examples = json.loads((ROOT / 'docs/examples/catalog.json').read_text())
    rendered = json.loads(typst('eval', '--in', ROOT / 'docs/manual.typ', '--format', 'json',
                                'query(<manual-example>).map(m => m.value)'))
    assert Counter(rendered) == Counter(e['id'] for e in examples)
    assert len(rendered) == len(set(rendered))
    # Default values must never accidentally become level-one headings/TOC entries.
    headings = json.loads(typst('eval', '--in', ROOT / 'docs/manual.typ', '--format', 'json',
                                'query(heading.where(level: 1)).map(h => h.body.text)'))
    assert len(headings) == 20, headings
    assert all(h not in ('auto', 'none', 'true', 'false') for h in headings)
    reader = PdfReader(pdf)
    assert len(reader.pages) >= 15, len(reader.pages)
    pages = {p.indirect_reference.idnum: i + 1 for i, p in enumerate(reader.pages)}
    linked_pages = []
    for page in reader.pages:
        for ref in page.get('/Annots', []):
            annotation = ref.get_object()
            target = annotation.get('/Dest', annotation.get('/A', {}).get('/D'))
            if hasattr(target, 'get_object'):
                target = target.get_object()
            if isinstance(target, list):
                assert target[0].idnum in pages
                linked_pages.append(pages[target[0].idnum])
    assert len(linked_pages) >= len(exports)
    assert {r['page'] for r in records} <= set(linked_pages)
    text = '\n'.join(p.extract_text() for p in reader.pages)
    for item in examples:
        assert item['title'] in text, item['title']
    # Page furniture alone is not a useful page: catch duplicate page breaks.
    assert all(len(p.extract_text().split()) > 15 for p in reader.pages)
    for badge in ('SETUP REQUIRED', 'NO SETUP', 'CONDITIONAL', 'INSTALLS SETUP', 'EXTENSION HOOK'):
        assert badge in text, badge
    with tempfile.TemporaryDirectory() as temp:
        bbox = Path(temp) / 'bbox.html'
        subprocess.run(['pdftotext', '-bbox', str(pdf), str(bbox)], check=True, capture_output=True)
        ns = {'x': 'http://www.w3.org/1999/xhtml'}
        tree = ET.parse(bbox)
        for i, page in enumerate(tree.findall('.//x:page', ns)):
            width, height = float(page.attrib['width']), float(page.attrib['height'])
            for word in page.findall('.//x:word', ns):
                x0, x1, y0, y1 = [float(word.attrib[key]) for key in ('xMin', 'xMax', 'yMin', 'yMax')]
                assert 40 <= x0 <= x1 <= width - 40, (i + 1, word.text, x0, x1)
                assert 20 <= y0 <= y1 <= height - 20, (i + 1, word.text, y0, y1)
    summary = dict(exports=len(exports), entries=len(model['selected']), pages=len(reader.pages),
                   worked_examples=len(rendered), preview_pages=sum(e['pages'] for e in examples),
                   headings=len(headings), internal_links=len(linked_pages), inputs=args.input, failures=0)
    (args.output / 'results.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(summary)


if __name__ == '__main__':
    main()
