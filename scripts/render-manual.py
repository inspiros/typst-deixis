#!/usr/bin/env python3
"""Build and validate the manual before optionally replacing the download PDF."""

import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tomllib

ROOT = Path(__file__).resolve().parents[1]


def manual_source_digest(root=ROOT):
    """Hash all print/runtime inputs; prose guides are independent of the PDF."""
    files = {root / 'typst.toml', root / 'docs/assets/examples/index.json',
             root / 'assets/logos/deixis-logo-horizontal.svg'}
    for folder, pattern in (('src', '**/*.typ'), ('docs', '**/*.typ'),
                            ('docs/reference', '*.json'), ('docs/examples', '*.json'),
                            ('docs/assets', '**/*.svg')):
        files.update((root / folder).glob(pattern))
    # Guide previews belong only to the website, not the downloadable manual.
    files = {path for path in files if not path.is_relative_to(root / 'docs/assets/guides')}
    digest = hashlib.sha256()
    for path in sorted(files):
        digest.update(path.relative_to(root).as_posix().encode() + b'\0')
        digest.update(path.read_bytes())
    return digest.hexdigest(), len(files)


def run(command):
    result = subprocess.run(list(map(str, command)), cwd=ROOT, text=True,
                            capture_output=True, timeout=120)
    if result.returncode or result.stderr:
        raise RuntimeError(result.stderr or result.stdout or f'Command failed: {command[0]}')
    return result.stdout


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--update-pdf', action='store_true', help='Validate, then update docs/manual.pdf and its build record.')
    parser.add_argument('--typst', default='typst', help='Typst executable to use.')
    parser.add_argument('--paper', choices=('a4', 'us-letter'), default='a4')
    parser.add_argument('--monochrome', action='store_true', help='Use neutral text/code styling.')
    args = parser.parse_args()
    # Reject stale previews before compiling or touching the checked-in artifact.
    run([sys.executable, ROOT / 'scripts/render-manual-examples.py', '--check'])
    output = ROOT / 'target/manual.pdf'
    output.parent.mkdir(parents=True, exist_ok=True)
    inputs = [f'paper={args.paper}', f'monochrome={str(args.monochrome).lower()}']
    flags = [arg for value in inputs for arg in ('--input', value)]
    run([args.typst, 'compile', '--root', ROOT, *flags, ROOT / 'docs/manual.typ', output])
    checks = ROOT / 'target/manual-check'
    run([sys.executable, ROOT / 'tests/manual.py', '--typst', args.typst,
         '--pdf', output, '--output', checks, *flags])
    if args.update_pdf:
        source_hash, count = manual_source_digest()
        version = tomllib.loads((ROOT / 'typst.toml').read_text())['package']['version']
        record = dict(version=version, compiler=run([args.typst, '--version']).strip(),
                      inputs=inputs, source_sha256=source_hash, source_files=count,
                      pdf_sha256=hashlib.sha256(output.read_bytes()).hexdigest(),
                      checks=json.loads((checks / 'results.json').read_text()))
        shutil.copy2(output, ROOT / 'docs/manual.pdf')
        (ROOT / 'docs/manual-build.json').write_text(json.dumps(record, indent=2) + '\n')
        print('Updated docs/manual.pdf and docs/manual-build.json after validation.')
    print(f'Built and validated {output}')


if __name__ == '__main__':
    main()
