#!/usr/bin/env python3
"""Build the local searchable website from guides, live API metadata and specimens."""

import argparse
from html import escape
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import textwrap
from urllib.parse import urlsplit, urlunsplit

ROOT = Path(__file__).resolve().parents[1]
STAGE = ROOT / 'target/site-source'
SPEC = importlib.util.spec_from_file_location('export_api', ROOT / 'scripts/export-api.py')
API = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(API)
GUIDE_SPEC = importlib.util.spec_from_file_location('guide_examples', ROOT / 'scripts/render-guide-examples.py')
GUIDES = importlib.util.module_from_spec(GUIDE_SPEC)
GUIDE_SPEC.loader.exec_module(GUIDES)


def source_prose(text):
    """Translate Tidy's reference/example fences for a Markdown reader."""
    text = re.sub(r'```ref\s+#?([^`]+)```', r'`\1`', text)
    text = re.sub(r'#link\("([^"\n]+)"\)\[([^\]\n]+)\]', r'[\2](\1)', text)
    lines = text.splitlines()
    if len(lines) > 1:
        # Tidy leaves one comment-space on continuation lines. Align both
        # opening and closing fences before passing them to Markdown.
        lines = [lines[0], *textwrap.dedent('\n'.join(lines[1:])).splitlines()]
    output = []
    containers = []
    code = None
    for line in lines:
        marker = re.fullmatch(r'\s*(`{3,})(\w*)\s*', line)
        if code:
            if marker and not marker[2] and len(marker[1]) >= len(code):
                output.append(code)
                code = None
            else:
                output.append(line)
        elif marker and marker[2] in ('info', 'tip', 'warning', 'memo', 'experiment'):
            containers.append(marker[1])
            output += ['', '**' + marker[2].capitalize() + '.**', '']
        elif marker and not marker[2] and containers:
            if len(marker[1]) != len(containers.pop()):
                raise ValueError('Mismatched Tidy prose container.')
            output.append('')
        elif marker:
            code = marker[1]
            output.append(code + ('typst' if marker[2] == 'example' else marker[2]))
        else:
            output.append(line)
    if code or containers:
        raise ValueError('Unclosed Tidy prose fence.')
    return '\n'.join(output)


def inline(text):
    return text.replace('|', '\\|').replace('\n', ' ').strip()


def transform_links(text, transform):
    """Transform prose destinations while leaving fenced source examples intact."""
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
            line = re.sub(r'\]\(([^\n)]+)\)', lambda m: '](' + transform(m[1], False) + ')', line)
            line = re.sub(r'\b(href|src)=([\'"])([^\'"]+)\2',
                          lambda m: m[1] + '=' + m[2] + transform(m[3], True) + m[2], line)
        lines.append(line)
    return ''.join(lines)


def normalize_directory_links(path):
    """Map repository indexes to their public book pages, including HTML links."""
    def replace(raw, html):
        parsed = urlsplit(raw)
        if not parsed.scheme and not parsed.netloc:
            target = (path.parent / parsed.path).resolve()
            aliases = {STAGE / 'docs/reference/README.md': STAGE / 'api/README.md',
                       STAGE / 'docs/examples/README.md': STAGE / 'gallery/README.md'}
            if target in aliases:
                parsed = parsed._replace(path=Path(os.path.relpath(aliases[target], path.parent)).as_posix())
                target = aliases[target]
            if target.is_dir() and (target / 'README.md').is_file():
                parsed = parsed._replace(path=parsed.path.rstrip('/') + '/README.md')
            if Path(parsed.path).name == 'README.md':
                parsed = parsed._replace(path=parsed.path[:-len('README.md')] + 'index.html')
            elif html and parsed.path.endswith('.md'):
                parsed = parsed._replace(path=parsed.path[:-3] + '.html')
        return urlunsplit(parsed)

    path.write_text(transform_links(path.read_text(), replace))


def home_page():
    source = ROOT / 'docs/site/home.md'

    def rebase(raw, html):
        parsed = urlsplit(raw)
        if not parsed.scheme and not parsed.netloc and parsed.path:
            target = (source.parent / parsed.path).resolve().relative_to(ROOT)
            parsed = parsed._replace(path=target.as_posix())
        return urlunsplit(parsed)

    return transform_links(source.read_text(), rebase)


def setup_badge(kind):
    label = {'setup': 'Setup Required', 'free': 'No Setup', 'conditional': 'Conditional', 'installs': 'Installs Setup'}[kind]
    return f'<span class="deixis-badge {kind}">{label}</span>'


def api_page(entry, group, functions):
    lines = ['<p class="deixis-kicker">API Reference</p>', '', '# ' + entry['names'][0], '', entry['summary'], '',
             setup_badge(entry['setup']), '', '**Returns:** ' + entry.get('returns', 'See source documentation.') + '.', '',
             '[Task guide](../docs/guides/' + entry.get('guide', group['guide']) + ')', '']
    if entry.get('call'):
        lines += ['## Example', '', '```typst', entry['call'], '```', '']
    if entry.get('note'):
        lines += [entry['note'], '']
    for name in entry['names']:
        function = functions[name]
        lines += ['## ' + name, '', '```typst', API.signature(function), '```', '',
                  source_prose(function['description']), '']
        if function.get('args'):
            lines += ['### Parameters', '', '| Name | Default | Types |', '| --- | --- | --- |']
            for arg, info in function['args'].items():
                default = '`' + inline(info['default']) + '`' if 'default' in info else ('variadic' if arg.startswith('..') else 'required')
                types = ', '.join(info.get('types', []))
                lines.append(f'| `{arg}` | {default} | {inline(types)} |')
            lines += ['']
            for arg, info in function['args'].items():
                if info.get('description'):
                    lines += ['#### ' + arg, '', source_prose(info['description']), '']
    return '\n'.join(lines)


def guide_nav():
    sections = []
    seen = set()
    current = None
    for line in (ROOT / 'docs/README.md').read_text().splitlines():
        if line.startswith('## '):
            current = []
            sections.append({line[3:]: current})
        for title, filename in re.findall(r'\[([^\]]+)\]\(guides/([^#)]+)(?:#[^)]*)?\)', line):
            if filename not in seen and current is not None:
                current.append({title: 'docs/guides/' + filename})
                seen.add(filename)
    expected = {p.name for p in (ROOT / 'docs/guides').glob('*.md')}
    if seen != expected:
        raise ValueError(f'Update docs/README.md guide navigation: missing={expected-seen}, unknown={seen-expected}')
    return [section for section in sections if next(iter(section.values()))]


def example_pages():
    nav = []
    cards = ['# Worked Examples', '', 'Compare exact source excerpts with real Typst output. Each example includes its complete editable source.', '', '<div class="deixis-cards">', '']
    for item in json.loads((ROOT / 'docs/examples/catalog.json').read_text()):
        path = (ROOT / 'docs' / item['source']).resolve()
        source = path.read_text()
        if item.get('excerpt') == 'touying':
            excerpt = source[source.index('  #pause'):source.index('  #v(0.5em)')].strip()
        else:
            excerpt = source.split('// BEGIN EXAMPLE\n', 1)[1].split('// END EXAMPLE', 1)[0].strip()
        relative = path.relative_to(ROOT).as_posix()
        lines = ['# ' + item['title'], '', item['caption'], '',
                 f'[Complete editable source](../{relative})', '', setup_badge(item['setup']), '',
                 '<div class="deixis-example">', '<div class="deixis-example-source">', '',
                 '## Source', '', '```typst', excerpt, '```', '',
                 '</div>', '<div class="deixis-example-output">', '', '## Output', '']
        for number in range(1, item['pages'] + 1):
            lines += [f'![{item["title"]}, page {number}](../docs/assets/examples/{item["id"]}-{number}.svg)', '']
        lines += ['</div>', '</div>', '']
        (STAGE / 'gallery' / (item['id'] + '.md')).write_text('\n'.join(lines))
        nav.append({item['title']: 'gallery/' + item['id'] + '.md'})
        cards += ['<div class="deixis-card">', '',
                  f'<a href="{item["id"]}.html"><img src="../docs/assets/examples/{item["id"]}-1.svg" alt="{escape(item["title"], quote=True)}"></a>', '',
                  f'### [{item["title"]}]({item["id"]}.md)', '', item['caption'], '',
                  setup_badge(item['setup']), '', '</div>', '']
    cards += ['</div>', '']
    (STAGE / 'gallery/README.md').write_text('\n'.join(cards))
    return [{'Overview': 'gallery/README.md'}, *nav]


def guide_examples():
    """Keep Markdown fences for mdBook's copy controls; pair with checked SVGs."""
    stamp = GUIDES.check_assets()
    previews = {item['key']: item for item in stamp['examples']}
    for path in sorted((STAGE / 'docs/guides').glob('*.md')):
        text = path.read_text()
        records = GUIDES.parse_markdown(text, path)
        for record in reversed(records):
            key = record['key']
            # Complete inputs make hidden setup discoverable and copyable.
            full = STAGE / 'docs/assets/guides' / (key + '.typ')
            full.write_text(GUIDES.example_source(record))
            alt = record['guide'].replace('-', ' ').capitalize() + ': ' + record['id'].replace('-', ' ')
            lines = [f'<div class="deixis-example deixis-guide-example" id="example-{record["id"]}">',
                     '<div class="deixis-example-source">', '',
                     '<p class="deixis-example-label">Source</p>', '',
                     '```typst', record['code'].rstrip(), '```', '',
                     f'[Complete source and preview setup](../assets/guides/{key}.typ)', '',
                     '</div>', '<div class="deixis-example-output">', '',
                     '<p class="deixis-example-label">Output · Click to zoom</p>', '']
            for number, asset in enumerate(previews[key]['assets'], 1):
                lines += [f'![{alt}, page {number}](../assets/guides/{asset})', '']
            lines += ['</div>', '</div>', '']
            text = text[:record['start']] + '\n'.join(lines) + text[record['end']:]
        # Fragments are deliberately code-only, with a visible explanation.
        text = re.sub(r'^```typst fragment\s*$',
                      '<p class="deixis-fragment-label">Fragment · Requires surrounding code</p>\n\n```typst',
                      text, flags=re.M)
        path.write_text(text)


def book_summary(api_nav, examples):
    """Every Markdown page needs a chapter to become HTML in mdBook."""
    lines = ['# Summary', '']
    included = set()

    def chapter(title, filename, level=0):
        if filename not in included:
            lines.append('  ' * level + '- [' + title + '](' + filename + ')')
            included.add(filename)

    chapter('Home', 'README.md')
    chapter('Guides', 'docs/README.md')
    for section in guide_nav():
        for item in next(iter(section.values())):
            chapter(next(iter(item)), next(iter(item.values())), 1)
    chapter('Public API', 'api/README.md')
    for section in api_nav[1:]:
        for item in next(iter(section.values())):
            chapter(next(iter(item)), next(iter(item.values())), 1)
    chapter('Worked Examples', 'gallery/README.md')
    for item in examples[1:]:
        chapter(next(iter(item)), next(iter(item.values())), 1)
    chapter('Editable Sources', 'examples/README.md', 1)
    chapter('Contributing', 'CONTRIBUTING.md')
    chapter('Architecture', 'docs/development/architecture.md', 1)
    chapter('Release Preparation', 'docs/development/release.md', 1)
    chapter('Coding Agent Guide', 'AGENTS.md', 1)
    chapter('Changelog', 'CHANGELOG.md', 1)
    chapter('Agent Skill', 'skills/deixis/SKILL.md')
    for path in sorted((STAGE / 'skills/deixis/references').glob('*.md')):
        match = re.search(r'^# (.+)$', path.read_text(), re.M)
        chapter(match[1], path.relative_to(STAGE).as_posix(), 1)
    expected = {p.relative_to(STAGE).as_posix() for p in STAGE.rglob('*.md') if p.name != 'SUMMARY.md'}
    if expected != included:
        raise ValueError(f'Unlisted public Markdown pages: {expected - included}')
    return '\n'.join(lines) + '\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--typst', default='typst')
    parser.add_argument('--mdbook', default='mdbook', help='mdBook executable (tested with 0.5.4).')
    args = parser.parse_args()
    print(subprocess.check_output([args.mdbook, '--version'], text=True).strip(), flush=True)
    # Refuse stale illustrative output before presenting it on the website.
    subprocess.run([sys.executable, ROOT / 'scripts/render-manual-examples.py', '--check'], check=True)
    subprocess.run([sys.executable, ROOT / 'scripts/render-guide-examples.py', '--check'], check=True)
    data = API.export_api(args.typst)
    if STAGE.exists():
        shutil.rmtree(STAGE)
    STAGE.mkdir(parents=True)
    for folder in ('docs/guides', 'docs/development', 'docs/examples', 'docs/assets', 'examples', 'assets', 'skills'):
        shutil.copytree(ROOT / folder, STAGE / folder, ignore=shutil.ignore_patterns('__pycache__', '*.pyc', 'README.md'))
    shutil.copyfile(ROOT / 'docs/README.md', STAGE / 'docs/README.md')
    shutil.copyfile(ROOT / 'docs/manual.pdf', STAGE / 'docs/manual.pdf')
    (STAGE / 'README.md').write_text(home_page())
    # Agent discovery metadata belongs to the portable skill, not its book page.
    skill_page = STAGE / 'skills/deixis/SKILL.md'
    skill_page.write_text(re.sub(r'\A---\n.*?\n---\n', '', skill_page.read_text(), flags=re.S).lstrip())
    for name in ('LICENSE', 'CONTRIBUTING.md', 'AGENTS.md', 'CHANGELOG.md'):
        shutil.copyfile(ROOT / name, STAGE / name)
    (STAGE / 'api').mkdir()
    (STAGE / 'gallery').mkdir()
    (STAGE / 'examples/README.md').write_text('# Editable Examples\n\n' +
        '\n'.join(f'- [{p.stem.replace("-", " ").title()}]({p.name})'
                  for p in sorted((ROOT / 'examples').glob('*.typ'))) + '\n')
    (STAGE / 'api/catalog.json').write_text(json.dumps(data, indent=2) + '\n')
    functions = {f['name']: f for f in data['functions']}
    api_nav = [{'Overview': 'api/README.md'}]
    index = ['# Public API', '', 'Generated from current source documentation through Tidy.', '',
             '[Download the machine-readable API](catalog.json).', '']
    for group in data['groups']:
        children = []
        index += ['## ' + group['title'], '', group['intro'], '']
        for entry in group['entries']:
            filename = entry['names'][0] + '.md'
            (STAGE / 'api' / filename).write_text(api_page(entry, group, functions))
            children.append({entry['names'][0]: 'api/' + filename})
            index += ['- [' + ' / '.join(entry['names']) + '](' + filename + ')']
        index += ['']
        api_nav.append({group['title']: children})
    (STAGE / 'api/README.md').write_text('\n'.join(index))
    guide_examples()
    (STAGE / 'SUMMARY.md').write_text(book_summary(api_nav, example_pages()))
    for path in STAGE.rglob('*.md'):
        if path.name != 'SUMMARY.md':
            normalize_directory_links(path)
    # Clear assets from the previous generator/build, including old search data.
    site = ROOT / 'target/site'
    if site.exists():
        shutil.rmtree(site)
    result = subprocess.run([args.mdbook, 'build', str(ROOT)], text=True, capture_output=True)
    if result.returncode or re.search(r'\bWARN(?:ING)?\b', result.stderr):
        raise RuntimeError(result.stderr or result.stdout)
    print(result.stderr or result.stdout, end='')
    subprocess.run([sys.executable, ROOT / 'tests/site.py'], check=True)


if __name__ == '__main__':
    main()
