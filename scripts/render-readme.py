#!/usr/bin/env python3
"""Render real Deixis specimens and the README hero; publish only on request."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'assets/readme'
OUTPUT = ROOT / 'target/readme'
SOURCES = ['examples/annotated-reading.typ', 'examples/annotated-equation.typ',
           'examples/editorial-review.typ', 'scripts/artwork/readme-hero.typ',
           'scripts/artwork/review-comparison.typ',
           'assets/logos/deixis-logo-horizontal.svg', 'scripts/render-readme.py',
           'scripts/artwork/hero-fragments.typ', 'examples/touying-reveals.typ',
           'scripts/artwork/slides-comparison.typ']
FRAGMENTS = ('text', 'equation', 'shared', 'diagram', 'editorial', 'footnote', 'outline', 'local')
NAMES = ('reading', 'equation', 'review-draft', 'review-final', 'hero', 'review',
         'slide-1', 'slide-2', 'slides') + tuple('hero-' + kind for kind in FRAGMENTS)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def inputs():
    paths = [ROOT / name for name in SOURCES] + sorted((ROOT / 'src').rglob('*.typ'))
    return {p.relative_to(ROOT).as_posix(): digest(p) for p in paths}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--typst', default='typst')
    parser.add_argument('--output-dir', type=Path, default=OUTPUT)
    parser.add_argument('--update-assets', action='store_true')
    parser.add_argument('--check', action='store_true', help='Verify bundled asset/input hashes.')
    args = parser.parse_args()
    if args.check:
        record = json.loads((ASSETS / 'index.json').read_text())
        assert record['inputs'] == inputs(), 'README inputs changed; rerun with --update-assets.'
        assert set(record['assets']) == {name + '.svg' for name in NAMES}
        assert all(digest(ASSETS / name) == checksum for name, checksum in record['assets'].items())
        print(f'{len(NAMES)} README illustrations are current.')
        return
    output = args.output_dir.resolve()
    output.mkdir(parents=True, exist_ok=True)
    packages = output / 'package-data'
    subprocess.run([sys.executable, ROOT / 'scripts/install.py', '--namespace', 'preview',
                    '--data-dir', packages, '--reinstall'], check=True, capture_output=True)

    def run(command):
        result = subprocess.run(list(map(str, command)), capture_output=True, text=True, timeout=120)
        if result.returncode or result.stderr:
            raise RuntimeError(result.stderr or result.stdout)
        return result.stdout

    with tempfile.TemporaryDirectory(prefix='readme-stage-', dir=ROOT / 'target') as directory:
        stage = Path(directory)

        def render(name, source, page=None, **values):
            flags = [arg for key, value in values.items() for arg in ('--input', f'{key}={value}')]
            if page is not None:  # One frame of a multi-page source; PDF tags need all pages.
                flags += ['--pages', str(page), '--no-pdf-tags']
            base = [args.typst, 'compile', '--root', ROOT, '--jobs', '1',
                    '--package-path', packages / 'typst/packages', *flags, ROOT / source]
            run([*base, stage / (name + '-{p}.svg')])
            pages = [p for p in stage.glob(name + '-*.svg')
                     if p.stem.removeprefix(name + '-').isdigit()]
            assert len(pages) == 1, f'{name}: expected one page, got {len(pages)}'
            pages[0].rename(stage / (name + '.svg'))
            run([*base, stage / (name + '.pdf')])
            run([*base, '--ppi', '120', stage / (name + '.png')])
            print('Rendered', name, flush=True)

        render('reading', SOURCES[0])
        render('equation', SOURCES[1])
        render('review-draft', SOURCES[2], final='false')
        render('review-final', SOURCES[2], final='true')
        virtual = lambda name: '/' + (stage / (name + '.svg')).relative_to(ROOT).as_posix()
        for kind in FRAGMENTS:
            render('hero-' + kind, SOURCES[7], kind=kind)
        render('hero', SOURCES[3], **{kind: virtual('hero-' + kind) for kind in FRAGMENTS})
        render('review', SOURCES[4], draft=virtual('review-draft'), final=virtual('review-final'))
        for page in (1, 2):
            render(f'slide-{page}', SOURCES[8], page=page)
        render('slides', SOURCES[9], first=virtual('slide-1'), second=virtual('slide-2'))
        record = dict(compiler=run([args.typst, '--version']).strip(), inputs=inputs(),
                      assets={name + '.svg': digest(stage / (name + '.svg')) for name in NAMES})
        for path in stage.iterdir():
            shutil.copy2(path, output / path.name)
        (output / 'index.json').write_text(json.dumps(record, indent=2) + '\n')
        if args.update_assets:
            ASSETS.mkdir(parents=True, exist_ok=True)
            for name in record['assets']:
                shutil.copy2(stage / name, ASSETS / name)
            shutil.copy2(output / 'index.json', ASSETS / 'index.json')
    print('Updated assets/readme/.' if args.update_assets else f'Preview only: {output}')


if __name__ == '__main__':
    main()
