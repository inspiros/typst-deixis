#!/usr/bin/env python3
"""Check local Markdown links/anchors and optionally the checked-in manual build."""

import argparse
from collections import Counter
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]


def prose(text):
    lines = []
    fence = None
    for line in text.splitlines():
        marker = re.match(r'^\s*(`{3,}|~{3,})', line)
        if marker:
            if fence is None:
                fence = marker[1]
            elif marker[1][0] == fence[0] and len(marker[1]) >= len(fence):
                fence = None
            continue
        if fence is None:
            lines.append(line)
    return '\n'.join(lines)


def anchors(path):
    result = set()
    counts = Counter()
    for line in prose(path.read_text()).splitlines():
        match = re.match(r'^#{1,6}\s+(.+?)\s*#*$', line)
        if not match:
            continue
        title = re.sub(r'<[^>]+>', '', match[1]).lower()
        slug = re.sub(r'[^\w\- ]', '', title).replace(' ', '-')
        suffix = counts[slug]
        counts[slug] += 1
        result.add(slug + (f'-{suffix}' if suffix else ''))
    result.update(re.findall(r'<(?:a|span)\s+[^>]*(?:id|name)=[\'"]([^\'"]+)', path.read_text()))
    return result


def check_manual():
    spec = importlib.util.spec_from_file_location('manual_builder', ROOT / 'scripts/render-manual.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    record = json.loads((ROOT / 'docs/manual-build.json').read_text())
    pdf = ROOT / 'docs/manual.pdf'
    assert record['pdf_sha256'] == hashlib.sha256(pdf.read_bytes()).hexdigest(), 'Manual PDF does not match its build record.'
    digest, count = module.manual_source_digest(ROOT)
    assert (record['source_sha256'], record['source_files']) == (digest, count), 'Manual inputs changed; rebuild with --update-pdf.'
    assert record['checks']['failures'] == 0
    assert record['version'] == __import__('tomllib').loads((ROOT / 'typst.toml').read_text())['package']['version']
    return record['checks']


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check-manual', action='store_true', help='Also check the release PDF/source hashes in docs/manual-build.json.')
    args = parser.parse_args()
    sources = sorted((ROOT / 'docs').rglob('*.md')) + [ROOT / name for name in
              ('README.md', 'CHANGELOG.md', 'AGENTS.md', 'CLAUDE.md', 'CONTRIBUTING.md')]
    failures = []
    checked = 0
    anchor_cache = {}
    for source in sources:
        text = prose(source.read_text())
        targets = re.findall(r'!?\[[^\]\n]*\]\(([^\n)]+)\)', text)
        targets += re.findall(r'<(?:img|a)\s+[^>]*(?:src|href)=[\'"]([^\'"]+)', text)
        for raw in targets:
            target = raw.strip().strip('<>')
            parsed = urlsplit(target)
            if parsed.scheme or parsed.netloc:
                continue
            path = (source.parent / unquote(parsed.path)).resolve() if parsed.path else source
            checked += 1
            label = source.relative_to(ROOT).as_posix()
            if not path.exists():
                failures.append(f'{label}: missing {raw}')
            elif path.suffix == '.md' and parsed.fragment:
                if path not in anchor_cache:
                    anchor_cache[path] = anchors(path)
                if unquote(parsed.fragment) not in anchor_cache[path]:
                    failures.append(f'{label}: missing anchor {raw}')
    assert (ROOT / 'CLAUDE.md').read_text().strip() == '@AGENTS.md', 'Keep one shared source of agent instructions.'
    if args.check_manual:
        try:
            manual = check_manual()
        except (AssertionError, OSError, KeyError) as error:
            failures.append(str(error))
    result = dict(markdown_files=len(sources), local_links=checked, failures=failures)
    output = ROOT / 'target/docs-check'
    output.mkdir(parents=True, exist_ok=True)
    (output / 'results.json').write_text(json.dumps(result, indent=2) + '\n')
    if failures:
        print('\n'.join(failures), file=sys.stderr)
        return 1
    if args.check_manual:
        result['manual'] = manual
    print(json.dumps(result))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
