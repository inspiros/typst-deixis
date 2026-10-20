"""Installer contracts: manifest exclusions and safe copied/linked reinstalls."""

from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class InstallTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.source = self.root / 'source'
        self.source.mkdir()
        (self.source / 'typst.toml').write_text(
            '[package]\nname="fixture"\nversion="0.1.0"\nentrypoint="src/lib.typ"\nexclude=["docs", "assets/gallery"]\n')
        for name in ('src/lib.typ', 'docs/manual.typ', 'assets/gallery/preview.svg', 'assets/runtime.svg', 'target/output.txt'):
            path = self.source / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(name)
        self.data = self.root / 'data'
        self.installed = self.data / 'typst/packages/local/fixture/0.1.0'

    def install(self, *args, success=True):
        result = subprocess.run([sys.executable, ROOT / 'scripts/install.py', '--root-dir', self.source,
                                 '--data-dir', self.data, *args], capture_output=True, text=True)
        self.assertEqual(result.returncode == 0, success, result.stderr)
        return result

    def test_copy_uses_manifest_paths(self):
        self.install()
        self.assertTrue((self.installed / 'src/lib.typ').is_file())
        self.assertTrue((self.installed / 'assets/runtime.svg').is_file())
        for name in ('docs', 'assets/gallery', 'target'):
            self.assertFalse((self.installed / name).exists())
        self.install(success=False)

    def test_link_reinstall_does_not_remove_source(self):
        self.install('--link')
        self.assertTrue(self.installed.is_symlink())
        self.install('--reinstall')
        self.assertFalse(self.installed.is_symlink())
        self.assertTrue((self.source / 'src/lib.typ').is_file())

    def test_recursive_install_is_rejected(self):
        self.data = self.source / 'unexcluded'
        self.assertIn('excluded directory', self.install(success=False).stderr)

    def test_preview_namespace_uses_the_manifest_version(self):
        # A local preview installation uses the editor's normal package search
        # path, without replacing a different cached/published version.
        self.install('--namespace', '@preview', '--link')
        preview = self.data / 'typst/packages/preview/fixture/0.1.0'
        self.assertTrue(preview.is_symlink())
        self.assertEqual(preview.resolve(), self.source)
        self.assertFalse(self.installed.exists())
        manifest = self.source / 'typst.toml'
        manifest.write_text(manifest.read_text().replace('version="0.1.0"', 'version="0.2.0"'))
        result = self.install('--namespace', 'preview', '--link')
        updated = preview.with_name('0.2.0')
        self.assertTrue(updated.is_symlink())
        self.assertIn('@preview/fixture:0.2.0', result.stdout)


if __name__ == '__main__':
    unittest.main()
