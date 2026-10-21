"""Exercise the local grammar against the actual mdBook highlight.js bundle."""

from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless(shutil.which('node') and shutil.which('mdbook'),
                     'Highlighting integration requires Node.js and mdBook')
class HighlightingTests(unittest.TestCase):
    def test_typst_tokens_copy_source_and_fail_safe(self):
        # Build a tiny book to use mdBook's installed bundle, without fetching
        # assets or requiring the full generated API/package installation.
        with tempfile.TemporaryDirectory(prefix='deixis-highlight-') as directory:
            book = Path(directory)
            (book / 'src').mkdir()
            (book / 'book.toml').write_text('[book]\ntitle = "Highlight Probe"\n')
            (book / 'src/SUMMARY.md').write_text('# Summary\n\n- [Probe](index.md)\n')
            (book / 'src/index.md').write_text('# Probe\n')
            subprocess.run(['mdbook', 'build', str(book)], check=True, capture_output=True, text=True)
            bundle, = (book / 'book').glob('highlight-*.js')
            result = subprocess.run(
                ['node', str(ROOT / 'tests/site_highlighting.js'), str(bundle),
                 str(ROOT / 'docs/site/theme/typst.js')],
                capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == '__main__':
    unittest.main()
