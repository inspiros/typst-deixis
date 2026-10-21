"""Universe README links must survive removal of checkout-only documentation."""

import importlib.util
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('prepare_universe', ROOT / 'scripts/prepare-universe.py')
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class UniverseReadmeTests(unittest.TestCase):
    def test_markdown_html_images_and_fragments(self):
        text, links = MODULE.rewrite_readme(
            '[Guide](docs/README.md#choose-a-starting-point) '
            '[PDF](docs/manual.pdf?raw=true) '
            '[![Preview](docs/assets/first-notes.svg)](examples/)\n'
            '<img src="assets/logos/deixis-logo-horizontal.svg">\n'
            '[Web](https://example.org/)\n```typst\n[Code](not-a-file)\n```\n',
            ROOT, 'https://github.com/inspiros/typst-deixis', 'v0.2.0')
        self.assertEqual(len(links), 5)
        self.assertIn('/blob/v0.2.0/docs/README.md#choose-a-starting-point', text)
        self.assertIn('/blob/v0.2.0/docs/manual.pdf?raw=true', text)
        self.assertIn('/tree/v0.2.0/examples', text)
        self.assertIn('https://raw.githubusercontent.com/inspiros/typst-deixis/v0.2.0/docs/assets/first-notes.svg', text)
        self.assertIn('[Web](https://example.org/)', text)
        self.assertIn('[Code](not-a-file)', text)

    def test_anchors_and_bundled_files_stay_relative(self):
        text, links = MODULE.rewrite_readme(
            '[Install](#install-the-checkout) [License](LICENSE)\n',
            ROOT, 'https://github.com/inspiros/typst-deixis', 'v0.2.0')
        self.assertEqual(text, '[Install](#install-the-checkout) [License](LICENSE)\n')
        self.assertEqual(links, [])

    def test_missing_and_escaping_targets_fail(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / 'source'
            root.mkdir()
            (root.parent / 'outside.md').write_text('outside')
            for target in ('missing.md', '../outside.md'):
                with self.subTest(target=target), self.assertRaises(ValueError):
                    MODULE.rewrite_readme(f'[Link]({target})', root,
                                          'https://github.com/owner/repo', 'v0.2.0')


if __name__ == '__main__':
    unittest.main()
