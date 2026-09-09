#!/usr/bin/env bash
# Confirms the busy process was actually found and stopped (not just the
# mount forced away), the disk cleanly unmounted, and no unrelated
# critical process was killed collaterally.

set -u

if pgrep -f "/usr/local/bin/vault-keeper" >/dev/null 2>&1; then
  echo "FAIL: vault-keeper process is still running - it must be stopped, not bypassed"
  exit 1
fi

if findmnt /mnt/locked-vault >/dev/null 2>&1; then
  echo "FAIL: /mnt/locked-vault is still mounted"
  exit 1
fi

if ! pgrep -x sshd >/dev/null 2>&1 && ! pgrep -f astrona >/dev/null 2>&1; then
  echo "FAIL: no sshd/astrona-agent process found running - an unrelated service may have been killed"
  exit 1
fi

echo "PASS: vault-keeper stopped, /mnt/locked-vault cleanly unmounted, no collateral damage"
exit 0
