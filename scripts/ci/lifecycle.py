#!/usr/bin/env python3
"""Exercise a fresh QEMU environment without submitting (which destroys it)."""
import argparse
import hashlib
import json
import re
import signal
import subprocess
import sys
import time
import platform
from pathlib import Path

import yaml


class InfrastructureError(RuntimeError):
    pass


class CommandTimeout(InfrastructureError):
    pass


class GradeError(RuntimeError):
    pass


def checked_grade(result, expectation=None):
    if result.returncode in (126, 127, 255) or result.returncode < 0:
        raise InfrastructureError(f"Grader could not execute: {result.stdout}")
    if expectation is not None:
        if result.returncode != 1 or not re.search(expectation, result.stdout):
            raise GradeError(f"Expected task failure /{expectation}/, got {result.returncode}: {result.stdout}")
    elif result.returncode:
        raise GradeError(f"Grader failed ({result.returncode}): {result.stdout}")


class Lifecycle:
    def __init__(self, directory, output):
        self.directory = directory.resolve()
        self.config = yaml.safe_load((directory / 'config.yaml').read_text())
        self.name = 'astro-' + self.config['metadata']['name']
        self.output = output.resolve()
        self.output.mkdir(parents=True, exist_ok=True)
        self.handles = {}
        self.results = []
        self.phase = 'configuration'
        self.spec = {}
        self.versions = {}
        self.image_records = []
        revision = subprocess.run(['git', '-C', str(self.directory), 'rev-parse', 'HEAD'],
                                  capture_output=True, text=True)
        self.revision = revision.stdout.strip() if revision.returncode == 0 else None
        dirty = subprocess.run(['git', '-C', str(self.directory), 'status', '--porcelain'],
                               capture_output=True, text=True)
        self.dirty = dirty.returncode != 0 or bool(dirty.stdout.strip())
        scenario = directory / 'testing/scenario.json'
        if scenario.exists():
            self.spec = json.loads(scenario.read_text())
        self.playground = self.config['metadata'].get('type') == 'playground' or 'playground' in directory.parts
        if not self.playground and not self.spec:
            raise InfrastructureError(f'Missing lifecycle scenario: {scenario}')

    def command(self, args, label, source=None, timeout=300):
        started = time.monotonic()
        try:
            result = subprocess.run(args, input=source, text=True, stdout=subprocess.PIPE,
                                    stderr=subprocess.STDOUT, timeout=timeout)
        except subprocess.TimeoutExpired as exc:
            text = exc.stdout or b''
            if isinstance(text, bytes):
                text = text.decode(errors='replace')
            (self.output / f'{len(self.results):03}-{label}.log').write_text(text)
            raise CommandTimeout(f'{label} timed out after {timeout}s') from exc
        (self.output / f'{len(self.results):03}-{label}.log').write_text(result.stdout)
        self.results.append({'phase': self.phase, 'step': label, 'exit': result.returncode,
                             'seconds': round(time.monotonic() - started, 2)})
        print(f'{self.phase}: {label}: exit {result.returncode}', flush=True)
        return result

    def cli(self, action, timeout=1200):
        result = self.command(['astrona', action, '-c', str(self.directory), '--headless',
                               '--accept-terms'] + (['--local-only'] if action == 'run' else []),
                              action, timeout=timeout)
        if result.returncode:
            raise InfrastructureError(f'astrona {action} failed: {result.stdout[-5000:]}')

    def record_images(self):
        host_arch = 'arm64' if platform.machine() in ('arm64', 'aarch64') else 'amd64'
        cache = Path.home() / '.astrona/cache/images'
        for vm in self.config['runtime']['qemu']:
            arch = vm.get('arch', host_arch)
            arch = {'x86_64': 'amd64', 'aarch64': 'arm64'}.get(arch, arch)
            source = vm['image']['source'].replace('{ARCH}', arch)
            records = []
            for path in cache.glob('*.meta.json'):
                meta = json.loads(path.read_text())
                if meta.get('source') == source:
                    records.append(meta)
            self.image_records.append({'vm': vm.get('name', 'default'), 'source': source,
                                       'architecture': arch, 'cache_metadata': records})

    def load_handles(self):
        vms = self.config['runtime']['qemu']
        for vm in vms:
            key = vm.get('name', 'default')
            name = self.name + ('-' + key if vm.get('name') else '')
            path = Path.home() / '.astrona/qemu' / name / 'handle.json'
            handle = json.loads(path.read_text())
            if handle['clusterName'] != name or handle.get('labName', name) != self.name:
                raise InfrastructureError(f'VM ownership mismatch for {name}')
            if handle['sshHost'] not in ('127.0.0.1', 'localhost', '::1'):
                raise InfrastructureError('Expected a local QEMU SSH port')
            self.handles[key] = handle

    def ssh(self, vm, source, label, timeout=180, learner=False):
        h = self.handles[vm]
        options = ['EscapeChar=none', 'PermitLocalCommand=no', 'ClearAllForwardings=yes',
                   'ForwardAgent=no', 'ForwardX11=no', 'IdentitiesOnly=yes', 'BatchMode=yes',
                   'ConnectTimeout=10', 'ServerAliveInterval=10', 'ServerAliveCountMax=3',
                   'StrictHostKeyChecking=accept-new', 'UserKnownHostsFile=' + h['knownHosts']]
        args = ['ssh', '-F', '/dev/null', '-i', h['sshKeyPath'] if learner else h['adminKeyPath'], '-p', str(h['sshPort'])]
        for option in options:
            args.extend(['-o', option])
        args.extend(['--', (h['sshUser'] if learner else h['adminUser']) + '@' + h['sshHost'], 'bash', '-s'])
        return self.command(args, label, source, timeout)

    def script(self, item, label):
        vm = item.get('vm', next(iter(self.handles)))
        path = (self.directory / item['script']).resolve()
        if not path.is_relative_to(self.directory):
            raise InfrastructureError(f'Script outside environment: {path}')
        source = path.read_text()
        delimiter = 'ASTRONA_REFERENCE_' + hashlib.sha256(source.encode()).hexdigest()
        command = ('script=$(mktemp)\ntrap \'rm -f "$script"\' EXIT\n'
                   + 'cat >"$script" <<\'' + delimiter + "'\n" + source + '\n' + delimiter
                   + '\nbash "$script" </dev/null\n')
        result = self.ssh(vm, command, label, item.get('timeout', 300), learner=True)
        if result.returncode:
            raise InfrastructureError(f'{label} failed ({result.returncode}): {result.stdout}')

    def graders(self):
        vms = self.config['runtime']['qemu']
        for vm in vms:
            key = vm.get('name', 'default')
            for scope in (self.config, vm):
                for item in scope.get('validation', {}).get('scripts', []):
                    if item['type'] != 'file':
                        raise InfrastructureError('CI requires explicit validation script files')
                    yield key, item

    def grade(self, expectations=None):
        found = set()
        for vm, item in self.graders():
            key = vm + '/' + item['name']
            result = self.ssh(vm, (self.directory / item['source']).read_text(),
                              re.sub('[^a-zA-Z0-9_-]', '-', key), self.spec.get('grader_timeout', 240))
            pattern = (expectations or {}).get(key)
            if expectations is None or pattern is not None:
                checked_grade(result, pattern)
            elif result.returncode not in (0, 1):
                raise InfrastructureError(f'Unexpected grader exit: {result.stdout}')
            found.add(key)
        if expectations is not None and not set(expectations) <= found:
            raise InfrastructureError(f'Unknown graders: {set(expectations) - found}')
        if not found and not self.playground:
            raise InfrastructureError('No graders found')

    def reboot(self, vm):
        before = self.ssh(vm, 'cat /proc/sys/kernel/random/boot_id', 'boot-id')
        checked_grade(before)
        requested = self.ssh(vm, 'sudo systemd-run --on-active=2s /usr/sbin/reboot', 'reboot')
        checked_grade(requested)
        deadline = time.monotonic() + self.spec.get('reboot_timeout', 180)
        while time.monotonic() < deadline:
            time.sleep(5)
            try:
                after = self.ssh(vm, 'cat /proc/sys/kernel/random/boot_id', 'wait-for-reboot', 20)
            except CommandTimeout:
                continue
            if after.returncode == 0 and after.stdout.strip() != before.stdout.strip():
                ready = self.ssh(vm, 'set -eu; timeout 90 cloud-init status --wait; test -d /run/systemd/system', 'boot-ready', 100)
                checked_grade(ready)
                return
        raise InfrastructureError(f'{vm} did not complete a reboot')

    def run(self):
        # Refuse to replace a running learner environment, even after a failed run.
        base = Path.home() / '.astrona/qemu'
        if (base / self.name).exists() or any(base.glob(self.name + '-*/handle.json')):
            raise InfrastructureError(f'{self.name} already exists; destroy it explicitly first')
        failure = None
        try:
            self.phase = 'versions'
            for binary in ('astrona', 'qemu-system-x86_64', 'qemu-system-aarch64', 'oras'):
                try:
                    result = self.command([binary, 'version' if binary == 'oras' else '--version'], 'version-' + binary, timeout=15)
                    self.versions[binary] = result.stdout.strip()
                except FileNotFoundError:
                    self.versions[binary] = 'not installed'
            self.phase = 'validate'
            self.cli('validate', 90)
            self.phase = 'bootstrap'
            self.cli('run')
            self.load_handles()
            self.record_images()
            self.phase = 'readiness'
            for vm in self.handles:
                checked_grade(self.ssh(vm, 'set -eu\ntest -d /run/systemd/system\nsudo -n true\n', 'ready-' + vm))
            if self.playground:
                for item in self.spec.get('smoke', []):
                    self.script(item, 'smoke')
            else:
                self.phase = 'unfinished'
                if not self.spec.get('initial_failures'):
                    raise InfrastructureError('Specify at least one intended unfinished-state failure')
                self.grade(self.spec['initial_failures'])
                self.phase = 'solution'
                for item in self.spec['solution']:
                    self.script(item, 'solution')
                self.phase = 'solved'
                self.grade()
                for case in self.spec.get('negative', []):
                    self.phase = 'negative-' + case['name']
                    for item in case['apply']:
                        self.script(item, 'mutate')
                    if not case.get('failures'):
                        raise InfrastructureError('Negative cases must name an expected failure')
                    self.grade(case['failures'])
                    for item in case['restore']:
                        self.script(item, 'restore')
                    self.grade()
                self.phase = 'persistence'
                for vm in self.spec.get('reboot', []):
                    self.reboot(vm)
                if self.spec.get('reboot'):
                    self.grade()
        except Exception as exc:
            failure = exc
            print(f'{type(exc).__name__}: {exc}', file=sys.stderr)
        finally:
            self.phase = 'diagnostics'
            for vm in self.handles:
                try:
                    self.ssh(vm, 'uname -a; systemctl --failed --no-pager; '
                             'ip -br address; ip route; sudo nft list ruleset; lsblk -f; sudo journalctl -b -p warning -n 100 --no-pager',
                             'diagnostics-' + vm, 30)
                except Exception as exc:
                    print(f'Diagnostics unavailable: {exc}', file=sys.stderr)
            self.phase = 'cleanup'
            try:
                self.cli('destroy', 180)
            except Exception as exc:
                failure = failure or exc
            (self.output / 'result.json').write_text(json.dumps({
                'environment': str(self.directory), 'revision': self.revision, 'dirty': self.dirty, 'status': 'failed' if failure else 'passed',
                'error_type': type(failure).__name__ if failure else None,
                'error': str(failure) if failure else None, 'steps': self.results,
                'images': [vm['image'] for vm in self.config['runtime']['qemu']],
                'resolved_images': self.image_records, 'tools': self.versions,
            }, indent=2) + '\n')
        if failure:
            raise failure


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('environment', type=Path)
    parser.add_argument('--output', type=Path, default=Path('test-results'))
    args = parser.parse_args()
    def interrupted(signum, frame):
        raise InfrastructureError(f'Interrupted by signal {signum}')
    signal.signal(signal.SIGTERM, interrupted)
    signal.signal(signal.SIGINT, interrupted)
    try:
        Lifecycle(args.environment, args.output).run()
    except GradeError:
        return 2
    except Exception as exc:
        print(f'{type(exc).__name__}: {exc}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
