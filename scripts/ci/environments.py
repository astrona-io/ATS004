#!/usr/bin/env python3
"""Discover all course environments and validate their local references."""
import argparse
import json
import subprocess
from pathlib import Path
import yaml


def discover(root):
    manifest = yaml.safe_load((root / 'astrona.yaml').read_text())
    registered = {}
    for module in manifest['modules']:
        for item in module['content']:
            path = root / item['path']
            if not path.exists():
                raise ValueError(f'Missing course content: {path}')
            if item['type'] == 'lab':
                if item['path'] in registered:
                    raise ValueError(f'Duplicate lab registration: {path}')
                registered[item['path']] = item
    question_ids = set()
    for bank in sorted(root.rglob('quiz.yaml')):
        data = yaml.safe_load(bank.read_text())
        for question in data.get('questions', []):
            identifier = question['id']
            if identifier in question_ids:
                raise ValueError(f'Duplicate question ID: {identifier}')
            question_ids.add(identifier)
            options = question['options']
            option_ids = [option['id'] for option in options]
            if question['type'] != 'single_choice' or len(set(option_ids)) != len(option_ids):
                raise ValueError(f'Invalid single-choice options: {bank}: {identifier}')
            if question['correct_option'] not in option_ids:
                raise ValueError(f'Unknown correct option: {bank}: {identifier}')
            if not question.get('source_readings'):
                raise ValueError(f'Question has no supporting lesson: {bank}: {identifier}')
            for reading in question['source_readings']:
                if not (root / reading).is_file():
                    raise ValueError(f'Missing question reading: {bank}: {reading}')
    names = set()
    found = set()
    environments = []
    for path in sorted(root.rglob('config.yaml')):
        if '.git' in path.parts:
            continue
        cfg = yaml.safe_load(path.read_text())
        if not isinstance(cfg, dict) or 'runtime' not in cfg or 'metadata' not in cfg:
            continue
        directory = path.parent
        relative = directory.relative_to(root).as_posix()
        name = cfg['metadata']['name']
        if name in names:
            raise ValueError(f'Duplicate environment name: {name}')
        names.add(name)
        kind = 'playground' if 'playground' in directory.parts else 'lab'
        if kind == 'lab':
            found.add(relative)
            if relative not in registered:
                raise ValueError(f'Unregistered lab: {relative}')
        for scope in [cfg] + cfg['runtime'].get('qemu', []):
            for section, key in [('bootstrap', 'init'), ('validation', 'scripts'), ('testing', 'init')]:
                for item in scope.get(section, {}).get(key, []):
                    if 'vm' in item:
                        raise ValueError(f'Unsupported vm field: {path}: {item["name"]}')
                    if item['type'] in ('file', 'folder') and not (directory / item['source']).exists():
                        raise ValueError(f'Missing {section} resource: {path}: {item["source"]}')
        for doc in cfg['metadata'].get('docs', {}).values():
            if not (directory / doc).is_file():
                raise ValueError(f'Missing lab document: {path}: {doc}')
        for script in directory.rglob('*.sh'):
            subprocess.run(['bash', '-n', str(script)], check=True)
        scenario_path = directory / 'testing/scenario.json'
        if not scenario_path.exists():
            raise ValueError(f'Missing lifecycle scenario: {relative}')
        if scenario_path.exists():
            scenario = json.loads(scenario_path.read_text())
            grader_keys = {
                vm.get('name', 'default') + '/' + item['name']
                for vm in cfg['runtime']['qemu']
                for scope in (cfg, vm)
                for item in scope.get('validation', {}).get('scripts', [])
            }
            expected = set(scenario.get('initial_failures', {}))
            for case in scenario.get('negative', []):
                expected.update(case['failures'])
            if expected - grader_keys:
                raise ValueError(f'Unknown grader in {scenario_path}: {expected - grader_keys}')
            if kind == 'lab' and (not scenario.get('solution') or not scenario.get('initial_failures')):
                raise ValueError(f'Lab needs a solution and an intended initial failure: {scenario_path}')
            if kind == 'playground' and not scenario.get('smoke'):
                raise ValueError(f'Playground needs a smoke check: {scenario_path}')
            steps = scenario.get('solution', []) + scenario.get('smoke', [])
            for case in scenario.get('negative', []):
                steps += case['apply'] + case['restore']
            vms = {vm.get('name', 'default') for vm in cfg['runtime']['qemu']}
            for step in steps:
                if step.get('vm', next(iter(vms))) not in vms:
                    raise ValueError(f'Unknown VM in {scenario_path}: {step}')
                if not (directory / step['script']).is_file():
                    raise ValueError(f'Missing test script: {scenario_path}: {step}')
        environments.append({'path': relative, 'kind': kind, 'name': name})
    if found != set(registered):
        raise ValueError(f'Registered labs without environments: {set(registered) - found}')
    return environments


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path('.'))
    args = parser.parse_args()
    print(json.dumps(discover(args.root)))
