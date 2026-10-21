"""Maintained guide directives and stale-preview detection."""

import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('guide_examples', ROOT / 'scripts/render-guide-examples.py')
GUIDES = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(GUIDES)


class GuideParserTests(unittest.TestCase):
    def test_source_offsets_and_hidden_setup(self):
        text = '# Heading\n\n<!-- deixis-example: {"id":"note","prelude":"#let word = [Hello]","postlude":"#word","setup":false} -->\n\n```typst\n#word\n```\n\nAfter.\n'
        record, = GUIDES.parse_markdown(text, Path('docs/guides/footnotes.md'))
        self.assertEqual(record['key'], 'footnotes--note')
        self.assertEqual(record['line'], 5)
        self.assertEqual(record['code'], '#word\n')
        self.assertEqual(text[:record['start']] + 'PAIR\n' + text[record['end']:], '# Heading\n\nPAIR\n\nAfter.\n')
        source = GUIDES.example_source(record)
        self.assertIn('#import "@preview/deixis:0.2.0": *', source)
        self.assertNotIn('#show: deixis-setup-notes', source)
        self.assertLess(source.index('#let word'), source.index('#word'))

    def test_directives_inside_code_are_ignored_and_ids_are_page_local(self):
        text = '````markdown\n<!-- deixis-example: not JSON -->\n```typst\nHi\n```\n````\n'
        self.assertEqual(GUIDES.parse_markdown(text, 'guide.md'), [])
        marked = '<!-- deixis-example: {"id":"note"} -->\n```typst\nHi\n```\n'
        one, = GUIDES.parse_markdown(marked, 'one.md')
        two, = GUIDES.parse_markdown(marked, 'two.md')
        self.assertNotEqual(one['key'], two['key'])

    def test_invalid_or_misplaced_directives_fail(self):
        invalid = [
            '```typst\nHi\n```',
            '<!-- deixis-example: not JSON -->\n```typst\nHi\n```',
            '<!-- deixis-example: {"id":"../bad"} -->\n```typst\nHi\n```',
            '<!-- deixis-example: {"id":"note","typo":true} -->\n```typst\nHi\n```',
            '<!-- deixis-example: {"id":"note","setup":"false"} -->\n```typst\nHi\n```',
            '<!-- deixis-example: {"id":"note"} -->\nProse\n```typst\nHi\n```',
            '<!-- deixis-example: {"id":"note"} -->\n```typst fragment\nHi\n```',
            '<!-- deixis-example: {"id":"note"} -->\n```python\nHi\n```',
            '<!-- deixis-example: {"id":"note"} -->\n```typst\nHi',
            '<!-- deixis-example: {"id":"note"} -->',
            '<!-- deixis-example: {"id":"note"} -->\n```typst\nHi\n```\n' * 2,
        ]
        for text in invalid:
            with self.subTest(text=text), self.assertRaises(ValueError):
                GUIDES.parse_markdown(text, 'guide.md')


class GuideFreshnessTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.page = self.root / 'docs/guides/guide.md'
        self.page.parent.mkdir(parents=True)
        self.page.write_text('<!-- deixis-example: {"id":"note"} -->\n```typst\nHello\n```\n')
        (self.root / 'src').mkdir()
        (self.root / 'src/lib.typ').write_text('runtime')
        (self.root / 'typst.toml').write_text('[package]\nversion="0.2.0"\n')
        self.assets = self.root / 'docs/assets/guides'
        self.assets.mkdir(parents=True)
        self.svg = self.assets / 'guide--note-1.svg'
        self.svg.write_text('<svg/>')
        record, = GUIDES.parse_guides(self.root)
        self.index = dict(format=1, compiler='typst fixture',
                          renderer_sha256=GUIDES.digest(Path(GUIDES.__file__)),
                          runtime_sha256=GUIDES.runtime_digest(self.root),
                          examples=[dict(guide='guide', id='note', key='guide--note',
                                         source_sha256=GUIDES.source_digest(record, self.root),
                                         assets={self.svg.name: GUIDES.digest(self.svg)})])
        self.save()

    def save(self):
        (self.assets / 'index.json').write_text(json.dumps(self.index))

    def test_prose_edits_do_not_stale_output_but_setup_edits_do(self):
        GUIDES.check_assets(self.root)
        self.page.write_text('# New Prose\n\n' + self.page.read_text())
        GUIDES.check_assets(self.root)
        self.page.write_text(self.page.read_text().replace('"id":"note"', '"id":"note","prelude":"#let n = 1"'))
        with self.assertRaisesRegex(ValueError, 'Stale guide example'):
            GUIDES.check_assets(self.root)

    def test_runtime_asset_renderer_and_catalogue_changes_are_detected(self):
        for kind in ('runtime', 'asset', 'renderer', 'catalogue', 'extra-asset', 'unsafe-asset'):
            with self.subTest(kind=kind):
                originals = {path: path.read_bytes() for path in self.root.rglob('*') if path.is_file()}
                if kind == 'runtime':
                    (self.root / 'src/lib.typ').write_text('changed')
                elif kind == 'asset':
                    self.svg.write_text('changed')
                elif kind == 'renderer':
                    index = json.loads((self.assets / 'index.json').read_text())
                    index['renderer_sha256'] = 'changed'
                    (self.assets / 'index.json').write_text(json.dumps(index))
                elif kind == 'catalogue':
                    self.page.write_text('No example now.\n')
                elif kind == 'extra-asset':
                    (self.assets / 'old.svg').write_text('<svg/>')
                elif kind == 'unsafe-asset':
                    index = json.loads((self.assets / 'index.json').read_text())
                    index['examples'][0]['assets'] = {'../../elsewhere.svg': 'checksum'}
                    (self.assets / 'index.json').write_text(json.dumps(index))
                with self.assertRaises(ValueError):
                    GUIDES.check_assets(self.root)
                for path in self.root.rglob('*'):
                    if path.is_file() and path not in originals:
                        path.unlink()
                for path, data in originals.items():
                    path.write_bytes(data)


if __name__ == '__main__':
    unittest.main()
