#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /opt/course/audit
for p in /bin /sbin /lib /lib64; do
 if test -L "$p"; then printf '%s -> %s
' "${p#/}" "$(readlink "$p")"; fi
done | sudo tee /opt/course/audit/symlinks.txt
sudo du --max-depth=1 -h -x / 2>/dev/null | grep -Ev '/(proc|sys|dev|run|bin|sbin|lib|lib64)$' | sort -rh | sudo tee /opt/course/audit/dirsizes.txt
