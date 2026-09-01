#!/usr/bin/env bash
# Checks that /opt/course/audit/dirsizes.txt is sorted largest-first.
# Tolerant of du-h-style sizes (4.0K, 1.2G, 178M) or plain byte counts,
# in either "SIZE\tPATH" or "SIZE PATH" order.

set -u

f=/opt/course/audit/dirsizes.txt

if [[ ! -f "$f" ]]; then
  echo "FAIL: dirsizes sorted - $f does not exist"
  exit 1
fi

result=$(awk '
function to_bytes(tok,    num, unit, mult) {
  if (tok ~ /^[0-9.]+$/) { return tok + 0 }
  unit = substr(tok, length(tok), 1)
  num = substr(tok, 1, length(tok) - 1) + 0
  if (unit == "K") mult = 1024
  else if (unit == "M") mult = 1024^2
  else if (unit == "G") mult = 1024^3
  else if (unit == "T") mult = 1024^4
  else { return tok + 0 }
  return num * mult
}
{
  size_tok = $1
  bytes = to_bytes(size_tok)
  if (NR > 1 && bytes > prev && !bad) {
    bad = 1
    badmsg = "line " NR " (" $0 ") is larger than the previous line"
  }
  prev = bytes
}
END {
  if (bad) { print "FAIL: " badmsg } else { print "OK" }
}
' "$f")

if [[ "$result" == "OK" ]]; then
  echo "PASS: dirsizes report is sorted largest-first"
  exit 0
else
  echo "FAIL: dirsizes sorted - ${result#FAIL: }"
  exit 1
fi
