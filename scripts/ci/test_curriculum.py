import tempfile
import unittest
from pathlib import Path
import yaml
from curriculum import check_distinct_labs, register_practice


class CurriculumTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for name in ('main', 'variant'):
            (self.root / name).mkdir()
        (self.root / 'lesson.md').write_text('Lesson')
        self.entry = {'path': 'variant', 'status': 'optional', 'reason': 'Different starting state',
                      'replacement': 'main', 'lessons': ['lesson.md'], 'learning_goals': ['Repair it']}

    def register(self):
        (self.root / 'practice.yaml').write_text(yaml.safe_dump({'labs': [self.entry]}))
        return register_practice(self.root, {'main': {}})

    def test_optional_variant_stays_discoverable(self):
        self.assertIn('variant', self.register())

    def test_missing_replacement_is_rejected(self):
        self.entry['replacement'] = 'absent'
        with self.assertRaisesRegex(ValueError, 'replacement'):
            self.register()

    def test_required_lab_cannot_also_be_optional(self):
        self.entry['path'] = 'main'
        with self.assertRaisesRegex(ValueError, 'already registered'):
            self.register()

    def test_missing_teaching_is_rejected(self):
        self.entry['lessons'] = ['missing.md']
        with self.assertRaisesRegex(ValueError, 'resource'):
            self.register()

    def test_external_practice_is_rejected(self):
        self.entry['lessons'] = ['../outside.md']
        with self.assertRaisesRegex(ValueError, 'external'):
            self.register()

    def assessment(self, name, filename, content):
        lab = self.root / name
        (lab / filename).write_text(content)
        (lab / 'config.yaml').write_text(yaml.safe_dump({
            'runtime': {'qemu': [{}]},
            'validation': {'scripts': [{'source': filename}]}}))

    def test_renamed_duplicate_grader_is_rejected(self):
        self.assessment('main', 'first.sh', 'check live state')
        self.assessment('variant', 'renamed.sh', 'check live state')
        with self.assertRaisesRegex(ValueError, 'Duplicate assessment'):
            check_distinct_labs(self.root, ['main', 'variant'])

    def test_different_outcomes_are_allowed(self):
        self.assessment('main', 'first.sh', 'check live state')
        self.assessment('variant', 'second.sh', 'check another outcome')
        check_distinct_labs(self.root, ['main', 'variant'])
