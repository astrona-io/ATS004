"""Check the main learning path and separately registered practice variants."""
import hashlib
from pathlib import Path
import yaml


def register_practice(root, required):
    path = root / 'practice.yaml'
    extra = {}
    if not path.exists():
        return extra
    for item in yaml.safe_load(path.read_text())['labs']:
        relative = item['path']
        if relative in required or relative in extra:
            raise ValueError(f'Practice lab is already registered: {relative}')
        if item['status'] not in ('optional', 'retired') or not item.get('reason'):
            raise ValueError(f'Practice lab needs a status and reason: {relative}')
        if item['replacement'] not in required:
            raise ValueError(f'Practice replacement is not in the main course: {relative}')
        if not item.get('lessons') or not item.get('learning_goals'):
            raise ValueError(f'Practice lab needs lessons and outcomes: {relative}')
        for source in [relative, *item['lessons']]:
            resolved = (root / source).resolve()
            if not resolved.is_relative_to(root.resolve()) or not resolved.exists():
                raise ValueError(f'Missing or external practice resource: {source}')
        extra[relative] = item
    return extra


def check_distinct_labs(root, required):
    """Reject copied assessments even when their filenames or titles differ."""
    seen = {}
    for relative in required:
        lab = root / relative
        cfg = yaml.safe_load((lab / 'config.yaml').read_text())
        graders = []
        for vm in cfg['runtime']['qemu']:
            for scope in (cfg, vm):
                graders.extend((lab / x['source']).read_bytes()
                               for x in scope.get('validation', {}).get('scripts', []))
        # Bootstrap and reference filenames may differ without changing the assessed work.
        if not graders:
            continue
        fingerprint = hashlib.sha256(b'\0'.join(sorted(graders))).hexdigest()
        if fingerprint in seen:
            raise ValueError(f'Duplicate assessment in main course: {seen[fingerprint]} and {relative}')
        seen[fingerprint] = relative
