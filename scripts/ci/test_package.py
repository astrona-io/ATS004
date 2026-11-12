"""Release evidence must describe the committed source being archived."""
import json
from pathlib import Path
import subprocess
import tarfile
import tempfile
import unittest
from unittest.mock import patch

from package import package


class PackageEvidenceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.root = self.base / 'repo'
        self.root.mkdir()
        self.reports = self.base / 'reports'
        self.reports.mkdir()
        self.output = self.base / 'output'
        (self.root / 'lesson.md').write_text('A committed lesson.\n')
        self.git('init', '-q')
        self.git('add', 'lesson.md')
        self.git('-c', 'user.name=CI', '-c', 'user.email=ci@example.invalid',
                 'commit', '-qm', 'test: create course fixture')
        self.revision = self.git('rev-parse', 'HEAD').strip()
        self.report = {'environment': '/runner/course/labs/example', 'status': 'passed',
                       'revision': self.revision, 'dirty': False}
        self.write_report()
        mock = patch('package.discover', return_value=[{'path': 'labs/example'}])
        mock.start()
        self.addCleanup(mock.stop)

    def git(self, *args):
        return subprocess.check_output(['git', '-C', str(self.root), *args], text=True)

    def write_report(self):
        (self.reports / 'result.json').write_text(json.dumps(self.report))

    def build(self):
        package(self.root, self.reports, self.output, 'v1.0.0')

    def test_success_archives_committed_files_and_evidence(self):
        (self.root / 'untracked-secret').write_text('must not be archived')
        self.build()
        with tarfile.open(self.output / 'course.tar.gz') as archive:
            self.assertIn('course/lesson.md', archive.getnames())
            self.assertNotIn('course/untracked-secret', archive.getnames())
        metadata = json.loads((self.output / 'course.json').read_text())
        self.assertEqual(metadata['revision'], self.revision)
        self.assertEqual(metadata['environment_count'], 1)

    def test_missing_report_blocks_release(self):
        (self.reports / 'result.json').unlink()
        with self.assertRaisesRegex(ValueError, 'every registered'):
            self.build()

    def test_failed_report_blocks_release(self):
        self.report['status'] = 'failed'
        self.write_report()
        with self.assertRaisesRegex(ValueError, 'unsuccessful'):
            self.build()

    def test_duplicate_report_blocks_release(self):
        extra = self.reports / 'duplicate'
        extra.mkdir()
        (extra / 'result.json').write_text(json.dumps(self.report))
        with self.assertRaisesRegex(ValueError, 'Duplicate'):
            self.build()

    def test_different_or_modified_source_blocks_release(self):
        for field, value in [('revision', 'another-commit'), ('dirty', True)]:
            with self.subTest(field=field):
                original = self.report[field]
                self.report[field] = value
                self.write_report()
                with self.assertRaisesRegex(ValueError, 'exact packaged revision'):
                    self.build()
                self.report[field] = original

    def test_local_tracked_change_blocks_release(self):
        (self.root / 'lesson.md').write_text('Changed after validation.\n')
        with self.assertRaisesRegex(ValueError, 'clean committed revision'):
            self.build()


if __name__ == '__main__':
    unittest.main()
