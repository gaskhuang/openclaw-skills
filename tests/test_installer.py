"""Offline behavioral tests. Git is mocked; all writes stay in a temporary directory."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'install.sh'
MOCK = '''#!/bin/sh
printf '%s\\n' "$*" >> "$MOCK_LOG"
case "$*" in
  *'remote get-url origin') printf '%s\\n' "$MOCK_ORIGIN" ;;
  *'status --porcelain') printf '%s' "$MOCK_CHANGES" ;;
  *) exit "$MOCK_RESULT" ;;
esac
'''

class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='installer-test-')
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.dest = self.root / 'skills with spaces'
        bin_dir = self.root / 'bin'
        bin_dir.mkdir()
        git = bin_dir / 'git'
        git.write_text(MOCK)
        git.chmod(0o755)
        self.log = self.root / 'git.log'
        self.env = dict(os.environ, PATH=str(bin_dir)+os.pathsep+os.environ['PATH'],
                        MOCK_LOG=str(self.log), MOCK_RESULT='0', MOCK_CHANGES='',
                        MOCK_ORIGIN='https://github.com/gaskhuang/openclaw-skill-agent-browser')

    def run_script(self, *args):
        return subprocess.run([os.environ.get('TEST_BASH', '/bin/bash'), str(SCRIPT), '--dir', str(self.dest), *args],
                              env=self.env, capture_output=True, text=True, errors='replace', timeout=10)

    def calls(self):
        return self.log.read_text() if self.log.exists() else ''

    def checkout(self):
        (self.dest / 'agent-browser' / '.git').mkdir(parents=True)

    def test_success_continues_and_counts(self):
        r = self.run_script('--only', 'agent-browser,agent-reach')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertEqual(self.calls().count('clone '), 2)
        self.assertIn('成功：2', r.stdout)

    def test_failure_continues_and_returns_nonzero(self):
        self.env['MOCK_RESULT'] = '1'
        r = self.run_script('--only', 'agent-browser,agent-reach')
        self.assertEqual(r.returncode, 1)
        self.assertEqual(self.calls().count('clone '), 2)
        self.assertIn('失敗：2', r.stdout)
        self.assertNotIn('🎉', r.stdout)

    def test_update_failure_counted(self):
        self.checkout()
        self.env['MOCK_RESULT'] = '1'
        r = self.run_script('--only', 'agent-browser')
        self.assertEqual(r.returncode, 1)
        self.assertIn('失敗：1', r.stdout)
        self.assertIn('pull --ff-only', self.calls())

    def test_update_success_counted(self):
        self.checkout()
        r = self.run_script('--only', 'agent-browser')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn('成功：1', r.stdout)

    def test_rejects_invalid_input_before_writes(self):
        for args in [('--only', '../outside'), ('--only', ''), ('--only', 'agent-browser,'),
                     ('--only', 'agent-browser,agent-browser'), ('--onyl', 'agent-browser'),
                     ('--only',), ('--dir',)]:
            with self.subTest(args=args):
                r = self.run_script(*args)
                self.assertEqual(r.returncode, 2)
                self.assertFalse(self.dest.exists())
                self.assertEqual(self.calls(), '')

    def test_foreign_origin_not_updated(self):
        self.checkout()
        self.env['MOCK_ORIGIN'] = 'https://example.invalid/other'
        r = self.run_script('--only', 'agent-browser')
        self.assertEqual(r.returncode, 1)
        self.assertNotIn('pull ', self.calls())

    def test_dirty_checkout_not_updated(self):
        self.checkout()
        self.env['MOCK_CHANGES'] = ' M SKILL.md'
        r = self.run_script('--only', 'agent-browser')
        self.assertEqual(r.returncode, 1)
        self.assertNotIn('pull ', self.calls())

    def test_symlink_not_updated(self):
        self.dest.mkdir()
        outside = self.root / 'outside'
        (outside / '.git').mkdir(parents=True)
        (self.dest / 'agent-browser').symlink_to(outside, target_is_directory=True)
        r = self.run_script('--only', 'agent-browser')
        self.assertEqual(r.returncode, 1)
        self.assertEqual(self.calls(), '')

    def test_existing_nonrepo_preserved(self):
        self.dest.mkdir()
        target = self.dest / 'agent-browser'
        target.write_text('preserve me')
        r = self.run_script('--only', 'agent-browser')
        self.assertEqual(r.returncode, 1)
        self.assertEqual(target.read_text(), 'preserve me')
        self.assertEqual(self.calls(), '')

    def test_help_has_no_side_effects(self):
        r = self.run_script('--help')
        self.assertEqual(r.returncode, 0)
        self.assertFalse(self.dest.exists())
        self.assertEqual(self.calls(), '')

if __name__ == '__main__':
    unittest.main()
