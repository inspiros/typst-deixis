"""Check progressive image zoom controls without external Node dependencies."""

from pathlib import Path
import shutil
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless(shutil.which('node'), 'Image zoom interaction check requires Node.js')
class ImageZoomTests(unittest.TestCase):
    def test_controls_and_navigation(self):
        result = subprocess.run(
            ['node', str(ROOT / 'tests/site_image_zoom.js'),
             str(ROOT / 'docs/site/theme/image-zoom.js')], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == '__main__':
    unittest.main()
