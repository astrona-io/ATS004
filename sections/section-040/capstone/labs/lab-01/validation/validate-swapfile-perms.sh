#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
# Confirms the active file-type swap area's backing file is mode 600 (or stricter).

set -u

name="$(swapon --show=NAME,TYPE --noheadings 2>/dev/null | awk '$2=="file"{print $1;exit}')"
if [[ -z "$name" ]]; then
  echo "FAIL: swapfile perms - no active file-type swap area found"
  exit 1
fi

if [[ ! -e "$name" ]]; then
  echo "FAIL: swapfile perms - $name not found on disk"
  exit 1
fi

mode="$(stat -c %a "$name")"
if [[ "$mode" != "600" ]]; then
  echo "FAIL: swapfile perms - $name has mode $mode, expected 600"
  exit 1
fi

echo "PASS: $name has secure permissions (600)"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
