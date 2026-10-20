#!/usr/bin/env python3
"""Prepare a local Universe package candidate with repository-absolute README links.

The supplied ref must exist before submission. This command does not create it,
contact GitHub, change the repository README, or publish anything.
"""

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import tomllib
from urllib.parse import quote, unquote, urlsplit, urlunsplit

ROOT = Path(__file__).resolve().parents[1]


def rewrite_readme(text, root, repository, ref):
    """Resolve local Markdown/HTML destinations against the source checkout."""
    repository = repository.rstrip('/')
    if not re.fullmatch(r'https://github\.com/[^/]+/[^/]+', repository):
        raise ValueError('Expected a GitHub repository URL in typst.toml.')
    if not ref or ref.startswith('-') or any(c.isspace() for c in ref):
        raise ValueError('Supply a nonempty tag or commit ref without whitespace.')
    records = []

    def destination(raw, image=False):
        parsed = urlsplit(raw.strip('<>'))
        if parsed.scheme or parsed.netloc:
            return raw
        path = (root / unquote(parsed.path)).resolve() if parsed.path else root / 'README.md'
        if not path.is_relative_to(root.resolve()) or not path.exists():
            raise ValueError(f'README target is missing or outside the checkout: {raw}')
        relative = path.relative_to(root.resolve()).as_posix()
        if image:
            base = repository.replace('github.com', 'raw.githubusercontent.com')
            url = f'{base}/{quote(ref, safe="")}/{quote(relative)}'
        else:
            kind = 'tree' if path.is_dir() else 'blob'
            url = f'{repository}/{kind}/{quote(ref, safe="")}/{quote(relative)}'
        parts = urlsplit(url)
        url = urlunsplit((parts.scheme, parts.netloc, parts.path, parsed.query, parsed.fragment))
        records.append(dict(source=raw, target=url, path=relative))
        return url

    lines = []
    fence = None
    for line in text.splitlines(keepends=True):
        marker = re.match(r'^\s*(`{3,}|~{3,})', line)
        if marker:
            if fence is None:
                fence = marker[1]
            elif marker[1][0] == fence[0] and len(marker[1]) >= len(fence):
                fence = None
        elif fence is None:
            def markdown_target(match):
                opening = line.rfind('[', 0, match.start())
                label = line[opening + 1:match.start()]
                image = opening > 0 and line[opening - 1] == '!' and ']' not in label
                return '](' + destination(match[1], image=image) + ')'

            # Scan destinations independently: linked images contain two, and
            # both must resolve after the documentation directory is excluded.
            line = re.sub(r'\]\(([^\n)]+)\)', markdown_target, line)
            line = re.sub(r'(<(?:img|a)\b[^>]*?\b(src|href)=)([\'"])([^\'"]+)\3',
                          lambda m: m[1] + m[3] + destination(m[4], image=m[2] == 'src') + m[3], line)
        lines.append(line)
    return ''.join(lines), records


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ref', required=True, help='Intended GitHub tag or commit; not created or verified remotely.')
    parser.add_argument('--output', type=Path, default=ROOT / 'target/universe-candidate')
    args = parser.parse_args()
    metadata = tomllib.loads((ROOT / 'typst.toml').read_text())['package']
    readme, links = rewrite_readme((ROOT / 'README.md').read_text(), ROOT, metadata['repository'], args.ref)
    output = args.output.resolve()
    # A candidate is disposable. Keep it inside the ignored output tree so it
    # cannot overwrite sources or be copied recursively into its own package.
    if not output.is_relative_to(ROOT / 'target'):
        parser.error('--output must be inside target/.')
    subprocess.run([sys.executable, ROOT / 'scripts/install.py', '--data-dir', output,
                    '--reinstall'], check=True)
    package = output / 'typst/packages/local' / metadata['name'] / metadata['version']
    (package / 'README.md').write_text(readme)
    files = sorted(p.relative_to(package).as_posix() for p in package.rglob('*') if p.is_file())
    allowed = {'README.md', 'LICENSE', 'typst.toml'}
    unexpected = [p for p in files if p not in allowed and not p.startswith('src/')]
    if unexpected:
        raise ValueError(f'Unexpected runtime package files: {unexpected}')
    record = dict(version=metadata['version'], ref=args.ref, remote_verified=False,
                  local_targets_checked=len(links), links=links, files=files,
                  sha256={p: hashlib.sha256((package / p).read_bytes()).hexdigest() for p in files})
    (output / 'inspection.json').write_text(json.dumps(record, indent=2) + '\n')
    print(f'Prepared {len(files)} runtime files; checked {len(links)} local README targets.')
    print('Candidate only: verify the ref and remote URLs after creating the release tag.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
