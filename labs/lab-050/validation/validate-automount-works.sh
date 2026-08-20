#!/usr/bin/env bash
# Triggers access to /mnt/auto/shared and confirms the NFS mount actually
# appears live -- writing the config alone is not enough.
set -u

if ! systemctl is-active --quiet autofs; then
  echo "FAIL: automount works - autofs service is not active"
  exit 1
fi

if ! ls /mnt/auto/shared >/dev/null 2>&1; then
  echo "FAIL: automount works - accessing /mnt/auto/shared failed (autofs did not mount it)"
  exit 1
fi

# Give automount a brief moment to complete the mount after the trigger.
mounted=0
for _ in $(seq 1 5); do
  if mount | grep -q '/mnt/auto/shared'; then
    mounted=1
    break
  fi
  sleep 1
done

if [[ "$mounted" -eq 1 ]]; then
  echo "PASS: /mnt/auto/shared automounted successfully"
  exit 0
else
  echo "FAIL: automount works - /mnt/auto/shared is not present in 'mount' output after access"
  exit 1
fi
