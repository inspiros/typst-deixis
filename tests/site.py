#!/usr/bin/env python3
"""Check generated local HTML destinations and searchable guide/export coverage."""

from html.parser import HTMLParser
import json
from pathlib import Path
import re
from urllib.parse import unquote, urljoin, urlsplit
import os

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / 'target/site'
SITE_URL = os.environ.get('MDBOOK_OUTPUT__HTML__SITE_URL', '/').rstrip('/') + '/'


class Page(HTMLParser):
    def __init__(self, path):
        super().__init__(convert_charrefs=True)
        self.anchors = set()
        self.links = []
        self.images = []
        self.content_images = []
        self.image_links = []
        self.typst_blocks = 0
        self.example_ids = []
        self.headings = []
        self.in_main = False
        self.feed(path.read_text())

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        self.anchors.update(attrs[key] for key in ('id', 'name') if key in attrs)
        self.links.extend(attrs[key] for key in ('href', 'src') if key in attrs)
        if tag == 'a':
            self.image_links.append(attrs.get('href'))
        if tag == 'img':
            self.images.append(attrs)
            if self.in_main:
                self.content_images.append((attrs, tuple(self.image_links)))
        if tag == 'code' and 'language-typst' in attrs.get('class', '').split():
            self.typst_blocks += 1
        if tag == 'div' and 'deixis-guide-example' in attrs.get('class', '').split():
            self.example_ids.append(attrs.get('id'))
        if tag == 'main':
            self.in_main = True
        if self.in_main and re.fullmatch(r'h[1-6]', tag):
            self.headings.append(tag)

    def handle_endtag(self, tag):
        if tag == 'a' and self.image_links:
            self.image_links.pop()
        if tag == 'main':
            self.in_main = False


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
    # Cover every generated chapter, not only the new guide pages.
    guide_index = json.loads((ROOT / 'docs/assets/guides/index.json').read_text())
    expected_guides = {}
    for record in guide_index['examples']:
        expected_guides.setdefault(record['guide'], []).append(record)
    for source, page in pages.items():
        if source.name in ('404.html', 'toc.html'):
            continue
        label = source.relative_to(SITE).as_posix()
        if not page.headings or page.headings[0] != 'h1':
            failures.append(f'{label}: missing leading chapter heading')
        if page.typst_blocks and not any(re.search(r'typst(?:-[a-z0-9]+)?\.js$', link) for link in page.links):
            failures.append(f'{label}: Typst highlighting asset missing')
        for asset in ('image-zoom.js', 'image-zoom.css'):
            if not any(re.search(r'image-zoom(?:-[a-z0-9]+)?\.' + asset.rsplit('.', 1)[1] + r'$',
                                 urlsplit(link).path) for link in page.links):
                failures.append(f'{label}: image zoom asset missing: {asset}')
        base_url = 'https://deixis.invalid' + SITE_URL + label
        def image_target(link):
            parsed = urlsplit(urljoin(base_url, link))
            return parsed.scheme, parsed.netloc, unquote(parsed.path)
        for image, ancestors in page.content_images:
            if any(link and image_target(link) == image_target(image.get('src', ''))
                   for link in ancestors):
                failures.append(f'{label}: content image links to its own file: {image.get("src")}')
        for image in page.images:
            if not image.get('alt', '').strip():
                failures.append(f'{label}: image has no text alternative')
        if source.parent == SITE / 'docs/guides':
            records = expected_guides.get(source.stem, [])
            if page.example_ids != ['example-' + record['id'] for record in records]:
                failures.append(f'{label}: source/output pair order or coverage changed')
            for record in records:
                preview_links = [f'../assets/guides/{asset}' for asset in record['assets']]
                if any(link not in page.links for link in preview_links):
                    failures.append(f'{label}: missing guide preview pages for {record["id"]}')
                complete = SITE / 'docs/assets/guides' / (record['key'] + '.typ')
                if not complete.is_file() or __import__('hashlib').sha256(complete.read_bytes()).hexdigest() != record['source_sha256']:
                    failures.append(f'{label}: complete guide source differs from rendered input')
    gallery = pages.get((SITE / 'gallery/index.html').resolve())
    for example in json.loads((ROOT / 'docs/examples/catalog.json').read_text()):
        image_src = f'../docs/assets/examples/{example["id"]}-1.svg'
        destination = example['id'] + '.html'
        if gallery is None or not any(image.get('src') == image_src and destination in ancestors
                                      for image, ancestors in gallery.content_images):
            failures.append(f'gallery/index.html: image card must navigate to {destination}')
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
                  searchable_exports=len(catalog['exports']), guide_examples=len(guide_index['examples']),
                  guide_preview_pages=sum(len(record['assets']) for record in guide_index['examples']), failures=failures)
    output.write_text(json.dumps(record, indent=2) + '\n')
    if failures:
        raise SystemExit('\n'.join(failures))
    print(json.dumps(record))


if __name__ == '__main__':
    main()
