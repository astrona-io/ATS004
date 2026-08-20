#!/usr/bin/env bash
# Confirms the busier of /mnt/backup-blue / /mnt/backup-red (computed live
# from df Used, not hardcoded) has an empty .trash directory. If one of the
# two has already been unmounted (expected once the process-disk step is
# done -- see validate-process-disk-unmounted.sh), that one obviously can't
# still be the "busier, needs emptying" target, so we fall back to
# whichever mountpoint is still up.

set -u

blue_used=-1
red_used=-1

if mountpoint -q /mnt/backup-blue; then
  blue_used=$(df --output=used /mnt/backup-blue | tail -1 | tr -d ' ')
fi

if mountpoint -q /mnt/backup-red; then
  red_used=$(df --output=used /mnt/backup-red | tail -1 | tr -d ' ')
fi

if [[ "$blue_used" -eq -1 && "$red_used" -eq -1 ]]; then
  echo "FAIL: trash emptied - neither /mnt/backup-blue nor /mnt/backup-red is mounted"
  exit 1
fi

if [[ "$blue_used" -ge "$red_used" ]]; then
  busier=/mnt/backup-blue
else
  busier=/mnt/backup-red
fi

trash="$busier/.trash"

if [[ ! -d "$trash" ]]; then
  echo "FAIL: trash emptied - $trash does not exist (busier disk: $busier)"
  exit 1
fi

remaining=$(find "$trash" -mindepth 1 | wc -l)
if [[ "$remaining" -ne 0 ]]; then
  echo "FAIL: trash emptied - $trash still has $remaining entr(y/ies) (busier disk: $busier)"
  exit 1
fi

echo "PASS: $trash is empty (busier disk: $busier)"
exit 0
