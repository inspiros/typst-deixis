#!/usr/bin/env python3
"""Build isolated source/output pairs for the manual; check freshness with --check."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / 'docs/examples/catalog.json'
ASSETS = ROOT / 'docs/assets/examples'
STAMP = ASSETS / 'index.json'
OUT = ROOT / 'target/manual-examples'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def runtime_digest():
    result = hashlib.sha256()
    for path in sorted((ROOT / 'src').rglob('*.typ')):
        result.update(path.relative_to(ROOT).as_posix().encode())
        result.update(path.read_bytes())
    return result.hexdigest()


def sources():
    return json.loads(CATALOG.read_text())


def source_path(item):
    return (ROOT / 'docs' / item['source']).resolve()


def check_assets():
    assert STAMP.is_file(), 'Missing manual examples. Run python3 scripts/render-manual-examples.py'
    stamp = json.loads(STAMP.read_text())
    assert stamp['runtime_sha256'] == runtime_digest(), 'Runtime changed; refresh manual examples with scripts/render-manual-examples.py'
    assert stamp['catalog_sha256'] == digest(CATALOG), 'Manual example catalogue changed; refresh previews.'
    assert {r['id'] for r in stamp['examples']} == {r['id'] for r in sources()}
    for item in sources():
        record = next(r for r in stamp['examples'] if r['id'] == item['id'])
        assert record['source_sha256'] == digest(source_path(item)), f"Stale source preview: {item['id']}"
        assert len(record['assets']) == item['pages']
        for name, checksum in record['assets'].items():
            assert digest(ASSETS / name) == checksum, f'Stale or missing preview: {name}'
    return stamp


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--typst', default='typst')
    parser.add_argument('--check', action='store_true', help='Verify source/runtime/asset digests without generating output.')
    args = parser.parse_args()
    if args.check:
        stamp = check_assets()
        print(f"{len(stamp['examples'])} source/output pairs are current.")
        return
    OUT.mkdir(parents=True, exist_ok=True)
    ASSETS.mkdir(parents=True, exist_ok=True)
    packages = OUT / 'package-data'
    subprocess.run([sys.executable, str(ROOT / 'scripts/install.py'), '--namespace', 'preview',
                    '--data-dir', str(packages), '--reinstall'], check=True, capture_output=True)
    package_path = packages / 'typst/packages'

    def build(item):
        source = source_path(item)
        flags = ['--root', str(ROOT), '--package-path', str(package_path)]
        targets = [OUT / f"{item['id']}.pdf", ASSETS / f"{item['id']}-{{p}}.svg"]
        for target in targets:
            result = subprocess.run([args.typst, 'compile', *flags, str(source), str(target)],
                                    text=True, capture_output=True, timeout=120)
            assert result.returncode == 0 and not result.stderr, (item['id'], result.stderr)
        actual = sorted(ASSETS.glob(f"{item['id']}-*.svg"))
        expected = [ASSETS / f"{item['id']}-{n}.svg" for n in range(1, item['pages'] + 1)]
        assert actual == expected, (item['id'], actual, expected)
        return dict(id=item['id'], source_sha256=digest(source),
                    assets={p.name: digest(p) for p in actual})

    with ThreadPoolExecutor(max_workers=2) as pool:
        records = list(pool.map(build, sources()))
    stamp = dict(compiler=subprocess.check_output([args.typst, '--version'], text=True).strip(),
                 runtime_sha256=runtime_digest(), catalog_sha256=digest(CATALOG), examples=records)
    STAMP.write_text(json.dumps(stamp, indent=2) + '\n')
    check_assets()
    print(f"Built {len(records)} isolated examples and {sum(len(r['assets']) for r in records)} SVG pages.")


if __name__ == '__main__':
    main()
