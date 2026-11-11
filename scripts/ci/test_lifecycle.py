import json
import tempfile
from pathlib import Path
from unittest.mock import patch
import subprocess
import unittest
from lifecycle import Lifecycle, checked_grade, GradeError, InfrastructureError, CommandTimeout


class GradeContract(unittest.TestCase):
    def result(self, code, output):
        return subprocess.CompletedProcess([], code, output)

    def test_expected_task_failure(self):
        checked_grade(self.result(1, 'FAIL: mount absent'), 'mount absent')

    def test_ssh_error_is_not_task_failure(self):
        with self.assertRaises(InfrastructureError):
            checked_grade(self.result(255, 'FAIL: mount absent'), 'mount absent')

    def test_missing_tool_is_not_task_failure(self):
        with self.assertRaises(InfrastructureError):
            checked_grade(self.result(127, 'command not found'), 'command')

    def test_unrelated_failure_rejected(self):
        with self.assertRaises(GradeError):
            checked_grade(self.result(1, 'FAIL: server not ready'), 'mount absent')

    def test_false_pass_rejected(self):
        with self.assertRaises(GradeError):
            checked_grade(self.result(0, 'PASS'), 'mount absent')

    def test_solution_must_pass(self):
        with self.assertRaises(GradeError):
            checked_grade(self.result(1, 'FAIL: mount absent'))


class VMHandles(unittest.TestCase):
    def load(self, vm_names, records):
        runner = Lifecycle.__new__(Lifecycle)
        runner.config = {'runtime': {'qemu': vm_names}}
        runner.name = 'astro-course-lab'
        runner.handles = {}
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            for name, fields in records.items():
                target = home / '.astrona/qemu' / name / 'handle.json'
                target.parent.mkdir(parents=True)
                target.write_text(json.dumps(fields))
            with patch('lifecycle.Path.home', return_value=home):
                runner.load_handles()
        return runner.handles

    def record(self, name, **changes):
        return dict(clusterName=name, labName='astro-course-lab',
                    sshHost='127.0.0.1', **changes)

    def test_single_named_vm_uses_suffix(self):
        name = 'astro-course-lab-host'
        handles = self.load([{'name': 'host'}], {name: self.record(name)})
        self.assertEqual(set(handles), {'host'})

    def test_unnamed_vm_uses_lab_name(self):
        name = 'astro-course-lab'
        handles = self.load([{}], {name: self.record(name)})
        self.assertEqual(set(handles), {'default'})

    def test_other_labs_handle_is_rejected(self):
        name = 'astro-course-lab-host'
        record = self.record(name)
        record['labName'] = 'another-lab'
        with self.assertRaises(InfrastructureError):
            self.load([{'name': 'host'}], {name: record})

    def test_nonlocal_ssh_endpoint_is_rejected(self):
        name = 'astro-course-lab-host'
        record = self.record(name)
        record['sshHost'] = 'example.com'
        with self.assertRaises(InfrastructureError):
            self.load([{'name': 'host'}], {name: record})


class RebootRetry(unittest.TestCase):
    def runner(self):
        runner = Lifecycle.__new__(Lifecycle)
        runner.spec = {'reboot_timeout': 60}
        return runner

    def test_ssh_timeout_during_reboot_is_retried(self):
        runner = self.runner()
        ok = lambda value: subprocess.CompletedProcess([], 0, value)
        responses = [ok('old-id'), ok('scheduled'), CommandTimeout('SSH unavailable'),
                     ok('new-id'), ok('ready')]
        with patch.object(runner, 'ssh', side_effect=responses) as ssh, \
             patch('lifecycle.time.sleep'):
            runner.reboot('default')
        self.assertEqual(ssh.call_count, 5)

    def test_retry_stops_at_reboot_deadline(self):
        runner = self.runner()
        ok = subprocess.CompletedProcess([], 0, 'old-id')
        with patch.object(runner, 'ssh', side_effect=[ok, ok, CommandTimeout('offline')]), \
             patch('lifecycle.time.sleep'), \
             patch('lifecycle.time.monotonic', side_effect=[0, 0, 61]):
            with self.assertRaisesRegex(InfrastructureError, 'did not complete a reboot'):
                runner.reboot('default')


if __name__ == '__main__':
    unittest.main()
