#!/usr/bin/env bash
# Confirms the disk backing the higher-memory process's executable is
# unmounted. Bootstrap fixes dark-matter-v2 at ~300MB resident vs
# dark-matter-v1's ~50MB (see bootstrap/02-dark-matter-processes.sh), so
# v2 always wins on both RSS and VSZ -- this is a deterministic property
# of the lab setup, not something the student's answer decides, so it's
# safe to check the concrete expected disk (/mnt/backup-red, where v2's
# executable lives) directly rather than re-deriving the winner live (the
# winning process must be stopped for the unmount to succeed at all, so
# it usually won't even be running by the time this check executes).

set -u

if mountpoint -q /mnt/backup-red; then
  echo "FAIL: process disk unmounted - /mnt/backup-red (dark-matter-v2's disk, the higher-memory process) is still mounted"
  exit 1
fi

if pgrep -f /mnt/backup-red/bin/dark-matter-v2 >/dev/null 2>&1; then
  echo "FAIL: process disk unmounted - dark-matter-v2 is still running, which would keep /mnt/backup-red busy"
  exit 1
fi

echo "PASS: /mnt/backup-red is unmounted and dark-matter-v2 is no longer running"
exit 0
