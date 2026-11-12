#!/usr/bin/env python3
"""Package a reviewed course revision with complete lifecycle evidence."""
import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path

from environments import discover


def package(root, reports, output, version):
    if not re.fullmatch(r'v[0-9]+\.[0-9]+\.[0-9]+(?:-[a-zA-Z0-9.-]+)?', version):
        raise ValueError('Use a version such as v1.2.0 or v1.2.0-rc.1')
    environments = discover(root)
    evidence = {}
    for path in reports.rglob('result.json'):
        result = json.loads(path.read_text())
        name = Path(result['environment']).as_posix()
        matches = [item['path'] for item in environments if name.endswith('/' + item['path'])]
        if len(matches) != 1:
            raise ValueError(f'Unknown or ambiguous environment in {path}: {name}')
        key = matches[0]
        if key in evidence or result['status'] != 'passed':
            raise ValueError(f'Duplicate or unsuccessful lifecycle report: {key}')
        evidence[key] = result
    if set(evidence) != {item['path'] for item in environments}:
        raise ValueError('Lifecycle reports must cover every registered lab and playground')
    revision = subprocess.check_output(['git', '-C', str(root), 'rev-parse', 'HEAD'], text=True).strip()
    if any(report.get('revision') != revision or report.get('dirty') is not False for report in evidence.values()):
        raise ValueError('Every lifecycle report must test the exact packaged revision')
    if subprocess.check_output(['git', '-C', str(root), 'status', '--porcelain', '--untracked-files=no'], text=True).strip():
        raise ValueError('Package only a clean committed revision')
    output.mkdir(parents=True, exist_ok=True)
    archive = output / 'course.tar.gz'
    subprocess.run(['git', '-C', str(root), 'archive', '--format=tar.gz', '--prefix=course/',
                    '-o', str(archive.resolve()), revision], check=True)
    metadata = {'schema_version': 1, 'version': version, 'revision': revision,
                'format': 'Astrona course source bundle', 'environment_count': len(environments),
                'validation': evidence,
                'note': 'VM disk images remain external dependencies identified in validation reports.'}
    (output / 'course.json').write_text(json.dumps(metadata, indent=2) + '\n')
    lines = []
    for path in (archive, output / 'course.json'):
        lines.append(hashlib.sha256(path.read_bytes()).hexdigest() + '  ' + path.name)
    (output / 'SHA256SUMS').write_text('\n'.join(lines) + '\n')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path('.'))
    parser.add_argument('--reports', type=Path, required=True)
    parser.add_argument('--output', type=Path, default=Path('dist'))
    parser.add_argument('--version', required=True)
    args = parser.parse_args()
    package(args.root, args.reports, args.output, args.version)
