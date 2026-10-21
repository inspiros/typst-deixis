#!/usr/bin/env python3
"""Check generated local HTML destinations and searchable guide/export coverage."""

from html.parser import HTMLParser
import json
from pathlib import Path
import re
from urllib.parse import unquote, urlsplit
import os

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / 'target/site'
SITE_URL = os.environ.get('MDBOOK_OUTPUT__HTML__SITE_URL', '/').rstrip('/') + '/'


class Page(HTMLParser):
    def __init__(self, path):
        super().__init__(convert_charrefs=True)
        self.anchors = set()
        self.links = []
        self.feed(path.read_text())

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        self.anchors.update(attrs[key] for key in ('id', 'name') if key in attrs)
        self.links.extend(attrs[key] for key in ('href', 'src') if key in attrs)


def main():
    pages = {p.resolve(): Page(p) for p in SITE.rglob('*.html')}
    assert pages, 'Build the website before checking it.'
    failures = []
    internal = ['tests', 'scripts', 'src', 'develop', 'target']
    internal += ['CLAUDE' + extension for extension in ('.md', '.html')]
    public_docs = {'guides', 'development', 'examples', 'assets', 'site'}
    internal += [p.relative_to(SITE).as_posix() for p in (SITE / 'docs').iterdir()
                 if p.is_dir() and p.name not in public_docs]
    for relative in internal:
        if (SITE / relative).exists():
            failures.append('Internal project material must not ship in the public guide: ' + relative)
    count = 0
    for source, page in pages.items():
        for link in page.links:
            parsed = urlsplit(link)
            if parsed.scheme or parsed.netloc:
                continue
            target = source
            if parsed.path:
                relative = unquote(parsed.path)
                # The Pages build sets a project prefix for its 404 page.
                if relative.startswith(SITE_URL):
                    relative = '/' + relative[len(SITE_URL):]
                target = (SITE / relative.lstrip('/') if relative.startswith('/') else
                          source.parent / relative).resolve()
            if target.is_dir():
                target = target / 'index.html'
            count += 1
            if not target.is_relative_to(SITE) or not target.is_file():
                failures.append(f'{source.relative_to(SITE)}: missing {link}')
            elif parsed.fragment and target in pages and unquote(parsed.fragment) not in pages[target].anchors:
                failures.append(f'{source.relative_to(SITE)}: missing anchor {link}')
    indexes = list(SITE.glob('searchindex*.js'))
    assert len(indexes) == 1, 'Expected one mdBook search index.'
    # mdBook serializes JSON inside a JS string, escaping backslashes and
    # apostrophes. Decode those two escapes without evaluating JavaScript.
    encoded = indexes[0].read_text().split("JSON.parse('", 1)[1].rsplit("')", 1)[0]
    data = json.loads(re.sub(r"\\([\\'])", lambda match: match[1], encoded))
    documents = data['index']['documentStore']['docs']
    search = [dict(location=data['doc_urls'][int(key)], title=value['title'], text=value['body'])
              for key, value in documents.items()]
    locations = {d['location'].split('#')[0] for d in search}
    for document in search:
        parsed = urlsplit(document['location'])
        target = (SITE / unquote(parsed.path)).resolve()
        if target not in pages or (parsed.fragment and unquote(parsed.fragment) not in pages[target].anchors):
            failures.append('Broken search destination: ' + document['location'])
    public_sources = [*(ROOT / 'docs/guides').glob('*.md'),
                      *(ROOT / 'docs/development').glob('*.md'),
                      ROOT / 'CONTRIBUTING.md', ROOT / 'AGENTS.md', ROOT / 'CHANGELOG.md']
    for source in public_sources:
        location = source.relative_to(ROOT).with_suffix('.html').as_posix()
        if location not in locations:
            failures.append(f'Public page is not searchable: {source.relative_to(ROOT)}')
    catalog = json.loads((SITE / 'api/catalog.json').read_text())
    searchable = '\n'.join(d['title'] + ' ' + d['text'] for d in search)
    for name in catalog['exports']:
        if name not in searchable:
            failures.append('Export is not searchable: ' + name)
    entries = 0
    for group in catalog['groups']:
        for entry in group['entries']:
            entries += 1
            location = 'api/' + entry['names'][0] + '.html'
            target = SITE / location
            if location not in locations or target not in pages:
                failures.append('API page is missing or not searchable: ' + location)
            else:
                for name in entry['names']:
                    if name not in pages[target].anchors:
                        failures.append('API export heading is missing: ' + name)
    output = ROOT / 'target/site-check.json'
    record = dict(html_pages=len(pages), local_links=count, search_entries=len(search), api_entries=entries,
                  searchable_exports=len(catalog['exports']), failures=failures)
    output.write_text(json.dumps(record, indent=2) + '\n')
    if failures:
        raise SystemExit('\n'.join(failures))
    print(json.dumps(record))


if __name__ == '__main__':
    main()
