import subprocess
import unittest
from lifecycle import checked_grade, GradeError, InfrastructureError


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


if __name__ == '__main__':
    unittest.main()
