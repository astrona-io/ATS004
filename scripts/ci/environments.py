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
        if kind == 'lab' and not scenario_path.exists():
            raise ValueError(f'Missing lifecycle scenario: {relative}')
        if scenario_path.exists():
            scenario = json.loads(scenario_path.read_text())
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
