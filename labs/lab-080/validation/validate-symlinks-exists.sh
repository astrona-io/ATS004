#!/usr/bin/env bash
# Checks that /opt/course/audit/symlinks.txt exists, is non-empty, and that
# every symlink path it names is actually a symlink on disk.

set -u

f=/opt/course/audit/symlinks.txt

if [[ ! -f "$f" ]]; then
  echo "FAIL: symlinks report - $f does not exist"
  exit 1
fi

if [[ ! -s "$f" ]]; then
  echo "FAIL: symlinks report - $f is empty"
  exit 1
fi

bad=0
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  name=$(awk '{print $1}' <<<"$line")
  path="/$name"
  if [[ ! -L "$path" ]]; then
    echo "FAIL: symlinks report - $path (from line: $line) is not a symlink"
    bad=1
  fi
done < "$f"

if [[ "$bad" -eq 1 ]]; then
  exit 1
fi

echo "PASS: symlinks report exists and every listed entry is a real symlink"
exit 0
