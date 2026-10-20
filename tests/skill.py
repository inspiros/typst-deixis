#!/usr/bin/env python3
"""Check the in-repo agent skill's exports, generated reference and runnable snippets."""

import argparse
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / 'skills/deixis'
SPEC = importlib.util.spec_from_file_location('export_api', ROOT / 'scripts/export-api.py')
API = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(API)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--typst', default='typst')
    args = parser.parse_args()
    data = API.export_api(args.typst)
    assert (SKILL / 'references/api.md').read_text() == API.cheat_sheet(data), 'Regenerate the API cheat sheet.'
    out = ROOT / 'target/skill-check' / data['version']
    out.mkdir(parents=True, exist_ok=True)
    subprocess.run([sys.executable, ROOT / 'scripts/install.py', '--namespace', 'preview',
                    '--data-dir', out / 'package-data', '--reinstall'], check=True, capture_output=True)
    flags = ['--root', str(ROOT), '--package-path', str(out / 'package-data/typst/packages')]
    names = set(data['exports'])
    snippets = []
    for path in sorted(SKILL.rglob('*.md')):
        text = path.read_text()
        mentioned = set(re.findall(r'\bdeixis-[a-z]+(?:-[a-z]+)*\b', text))
        assert not mentioned - names, f'{path}: unknown public names {mentioned-names}'
        for number, snippet in enumerate(re.findall(r'```typst\n(.*?)\n```', text, re.S), 1):
            source = out / f'{path.stem}-{number}.typ'
            source.write_text(snippet + '\n')
            result = subprocess.run([args.typst, 'compile', *flags, source, source.with_suffix('.pdf')],
                                    text=True, capture_output=True, timeout=120)
            assert result.returncode == 0 and not result.stderr, f'{path}:{number}\n{result.stderr}'
            snippets.append(dict(source=str(source.relative_to(ROOT)), document=str(path.relative_to(ROOT)), snippet=number))
    assert len(snippets) >= 4, 'The setup and three task recipes must remain runnable.'
    record = dict(compiler=subprocess.check_output([args.typst, '--version'], text=True).strip(),
                  exports=len(names), snippets=snippets)
    (out / 'results.json').write_text(json.dumps(record, indent=2) + '\n')
    print(f'{record["compiler"]}: checked {len(names)} exports and {len(snippets)} runnable snippets.')


if __name__ == '__main__':
    main()
