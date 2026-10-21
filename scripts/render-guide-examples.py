#!/usr/bin/env python3
"""Render marked guide snippets against an isolated installed package.

Place ``<!-- deixis-example: {"id":"name"} -->`` immediately before a
Typst fence. Optional width, height, margin, prelude, postlude and setup keys
control the isolated document; only the fence body appears in the website.
"""

import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tomllib

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'docs/assets/guides'
DIRECTIVE = re.compile(r'^\s*<!--\s*deixis-example:\s*(.*?)\s*-->\s*$')
FENCE = re.compile(r'^\s*(`{3,}|~{3,})([^\n]*)\s*$')
OPTIONS = {'id', 'width', 'height', 'margin', 'prelude', 'postlude', 'setup'}


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def digest(path):
    return sha256(path.read_bytes())


def parse_markdown(text, path):
    """Return marked fences, with replacement offsets into the original text."""
    path = Path(path)
    lines = text.splitlines(keepends=True)
    offsets = [0]
    for line in lines:
        offsets.append(offsets[-1] + len(line))
    records, ids = [], set()
    pending = None
    index = 0
    while index < len(lines):
        line = lines[index]
        directive = DIRECTIVE.fullmatch(line.rstrip('\r\n'))
        if directive:
            if pending is not None:
                raise ValueError(f'{path}:{index + 1}: example directive has no fence')
            try:
                config = json.loads(directive[1])
            except json.JSONDecodeError as error:
                raise ValueError(f'{path}:{index + 1}: invalid example JSON: {error}') from error
            if not isinstance(config, dict) or set(config) - OPTIONS:
                raise ValueError(f'{path}:{index + 1}: unknown example options')
            ident = config.get('id', '')
            if not isinstance(ident, str) or not re.fullmatch(r'[a-z0-9]+(?:-[a-z0-9]+)*', ident):
                raise ValueError(f'{path}:{index + 1}: example id must be a lowercase slug')
            if ident in ids:
                raise ValueError(f'{path}:{index + 1}: duplicate example id {ident}')
            if 'setup' in config and not isinstance(config['setup'], bool):
                raise ValueError(f'{path}:{index + 1}: setup must be true or false')
            for key in OPTIONS - {'id', 'setup'}:
                if key in config and (not isinstance(config[key], str) or not config[key].strip()):
                    raise ValueError(f'{path}:{index + 1}: {key} must be a nonempty string')
            pending = (index, config)
            index += 1
            continue
        if 'deixis-example:' in line:
            raise ValueError(f'{path}:{index + 1}: malformed example directive')
        opening = FENCE.fullmatch(line.rstrip('\r\n'))
        if opening:
            start = index
            index += 1
            while index < len(lines):
                closing = FENCE.fullmatch(lines[index].rstrip('\r\n'))
                if closing and closing[1][0] == opening[1][0] and len(closing[1]) >= len(opening[1]) and not closing[2].strip():
                    break
                index += 1
            if index == len(lines):
                raise ValueError(f'{path}:{start + 1}: unclosed code fence')
            if pending:
                if opening[2].strip() != 'typst':
                    raise ValueError(f'{path}:{start + 1}: example directive requires a plain typst fence')
                marker, config = pending
                ident = config['id']
                ids.add(ident)
                records.append(dict(guide=path.stem, id=ident, key=f'{path.stem}--{ident}',
                                    path=path, page=path, line=start + 1,
                                    start=offsets[marker], end=offsets[index + 1],
                                    code=''.join(lines[start + 1:index]), options=config, config=config))
                pending = None
            elif opening[2].strip() == 'typst':
                raise ValueError(f'{path}:{start + 1}: classify Typst code with an example directive or typst fragment')
            index += 1
            continue
        if pending and line.strip():
            raise ValueError(f'{path}:{index + 1}: example directive must precede its fence')
        index += 1
    if pending:
        raise ValueError(f'{path}: example directive has no fence')
    return records


def parse_guides(root=ROOT):
    return [record for page in sorted((root / 'docs/guides').glob('*.md'))
            for record in parse_markdown(page.read_text(), page)]


def example_source(record, root=ROOT):
    config = record['config']
    version = tomllib.loads((root / 'typst.toml').read_text())['package']['version']
    preamble = [f'#import "@preview/deixis:{version}": *',
                '#set page(width: ' + config.get('width', '360pt') + ', height: ' +
                config.get('height', 'auto') + ', margin: ' + config.get('margin', '18pt') + ')',
                '#set text(font: "DejaVu Serif", size: 10pt)']
    if config.get('setup', True):
        preamble.append('#show: deixis-setup-notes')
    return '\n'.join(preamble) + '\n' + config.get('prelude', '') + '\n' + record['code'] + '\n' + config.get('postlude', '') + '\n'


def runtime_digest(root=ROOT):
    result = hashlib.sha256()
    for path in sorted((root / 'src').rglob('*.typ')) + [root / 'typst.toml']:
        result.update(path.relative_to(root).as_posix().encode())
        result.update(path.read_bytes())
    return result.hexdigest()


def source_digest(record, root=ROOT):
    return sha256(example_source(record, root).encode())


def check_assets(root=ROOT, assets=None):
    assets = assets if assets is not None else root / 'docs/assets/guides'
    refresh = 'Run python3 scripts/render-guide-examples.py'
    stamp = json.loads((assets / 'index.json').read_text())
    if stamp.get('format') != 1 or stamp.get('renderer_sha256') != digest(Path(__file__)):
        raise ValueError(f'Guide preview renderer changed. {refresh}')
    if stamp.get('runtime_sha256') != runtime_digest(root):
        raise ValueError(f'Guide preview runtime changed. {refresh}')
    records = parse_guides(root)
    saved = {record['key']: record for record in stamp['examples']}
    if len(saved) != len(stamp['examples']) or set(saved) != {record['key'] for record in records}:
        raise ValueError(f'Guide preview catalogue changed. {refresh}')
    expected_assets = set()
    for record in records:
        stored = saved[record['key']]
        if stored['source_sha256'] != source_digest(record, root):
            raise ValueError(f"Stale guide example {record['key']}. {refresh}")
        if not stored['assets']:
            raise ValueError(f"Guide example {record['key']} has no pages")
        for name, checksum in stored['assets'].items():
            if not re.fullmatch(re.escape(record['key']) + r'-[1-9][0-9]*\.svg', name):
                raise ValueError(f'Invalid guide asset name: {name}')
            if not (assets / name).is_file() or digest(assets / name) != checksum:
                raise ValueError(f'Stale or missing guide preview {name}. {refresh}')
            expected_assets.add(name)
    if {path.name for path in assets.glob('*.svg')} != expected_assets:
        raise ValueError(f'Unexpected guide preview files. {refresh}')
    return stamp


def render(compiler, output, work, jobs):
    records = parse_guides()
    if not records:
        raise ValueError('No marked guide examples found')
    work.mkdir(parents=True, exist_ok=True)
    staging = work / 'assets'
    if staging.exists():
        shutil.rmtree(staging)
    staging.mkdir()
    packages = work / 'package-data'
    install = subprocess.run([sys.executable, str(ROOT / 'scripts/install.py'), '--namespace', 'preview',
                              '--data-dir', str(packages), '--reinstall'], text=True, capture_output=True)
    (work / 'install.log').write_text(install.stdout + install.stderr)
    install.check_returncode()
    sources = work / 'sources'
    sources.mkdir(exist_ok=True)

    def build(record):
        key = record['key']
        source = sources / f'{key}.typ'
        source.write_text(example_source(record))
        command = [compiler, 'compile', '--root', str(ROOT), '--package-path',
                   str(packages / 'typst/packages'), str(source), str(staging / f'{key}-{{p}}.svg')]
        result = subprocess.run(command, text=True, capture_output=True, timeout=120)
        (work / f'{key}.log').write_text(result.stdout + result.stderr)
        if result.returncode or result.stderr.strip():
            raise ValueError(f"{record['path'].relative_to(ROOT)}:{record['line']} ({key}):\n{result.stderr}")
        pages = sorted(staging.glob(f'{key}-*.svg'), key=lambda path: int(path.stem.rsplit('-', 1)[1]))
        if not pages:
            raise ValueError(f'{key}: compiler produced no pages')
        return dict(guide=record['guide'], id=record['id'], key=key,
                    source_sha256=source_digest(record), assets={page.name: digest(page) for page in pages})

    built, errors = {}, []
    with ThreadPoolExecutor(max_workers=jobs) as pool:
        pending = {pool.submit(build, record): record for record in records}
        for future in as_completed(pending):
            try:
                result = future.result()
                built[result['key']] = result
            except (ValueError, OSError, subprocess.SubprocessError) as error:
                errors.append(str(error))
    if errors:
        raise ValueError('\n\n'.join(errors))
    stamp = dict(format=1, compiler=subprocess.check_output([compiler, '--version'], text=True).strip(),
                 renderer_sha256=digest(Path(__file__)), runtime_sha256=runtime_digest(),
                 examples=[built[record['key']] for record in records])
    (staging / 'index.json').write_text(json.dumps(stamp, indent=2) + '\n')
    # Leave the committed set intact if any specimen fails to compile.
    if output.resolve() != staging.resolve():
        output.mkdir(parents=True, exist_ok=True)
        for old in output.glob('*.svg'):
            old.unlink()
        for page in staging.iterdir():
            shutil.copy2(page, output / page.name)
    check_assets(assets=output)
    return stamp


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--typst', default='typst')
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--check', action='store_true', help='Check source, renderer, runtime and asset digests without compiling.')
    mode.add_argument('--verify', action='store_true', help='Compile to target only, preserving committed previews (e.g. with a second compiler).')
    parser.add_argument('--output', type=Path, help='Alternative SVG/index directory.')
    parser.add_argument('--work-dir', type=Path, default=ROOT / 'target/guide-examples', help='Isolated package, generated sources and per-example compiler logs.')
    parser.add_argument('--jobs', type=int, default=2)
    args = parser.parse_args()
    if args.jobs < 1:
        parser.error('--jobs must be positive')
    work = args.work_dir.resolve()
    output = args.output.resolve() if args.output else (work / 'assets' if args.verify else ASSETS)
    try:
        stamp = check_assets(assets=output) if args.check else render(args.typst, output, work, args.jobs)
    except (ValueError, OSError, KeyError, subprocess.SubprocessError) as error:
        print(error, file=sys.stderr)
        return 1
    print(f"{len(stamp['examples'])} guide examples / {sum(len(item['assets']) for item in stamp['examples'])} SVG pages " +
          ('are current.' if args.check else f"rendered with {stamp['compiler']}."))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
