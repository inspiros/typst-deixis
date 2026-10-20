#!/usr/bin/env python3
"""Render maintained examples against an isolated copy of this checkout."""

import argparse
from pathlib import Path
import subprocess
import sys
import shutil
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output-dir', type=Path, default=ROOT / 'target/gallery')
    args = parser.parse_args()
    data = ROOT / 'target/artwork-package-data'
    subprocess.run([sys.executable, ROOT / 'scripts/install.py', '--namespace', 'preview',
                    '--data-dir', data, '--reinstall'], check=True)
    output = args.output_dir
    output.mkdir(parents=True, exist_ok=True)
    sources = sorted((ROOT / 'examples').glob('*.typ'))
    with tempfile.TemporaryDirectory(prefix='gallery-stage-', dir=ROOT / 'target') as directory:
        staged = Path(directory)
        for source in sources:
            result = subprocess.run(['typst', 'compile', '--root', str(ROOT), '--package-path',
                                     str(data / 'typst/packages'), str(source),
                                     str(staged / (source.stem + '-{p}.svg'))],
                                    capture_output=True, text=True, timeout=120)
            if result.returncode or result.stderr:
                raise RuntimeError(f'{source.name}: {result.stderr}')
            print(f'Rendered {source.name}')
        # Refresh only after the complete batch succeeds; remove obsolete pages.
        for source in sources:
            def owned_pages(directory):
                return [page for page in directory.glob(source.stem + '-*.svg')
                        if page.stem.removeprefix(source.stem + '-').isdigit()]
            pages = owned_pages(staged)
            names = {page.name for page in pages}
            for obsolete in owned_pages(output):
                if obsolete.name not in names:
                    obsolete.unlink()
            for page in pages:
                shutil.copy2(page, output / page.name)


if __name__ == '__main__':
    main()
