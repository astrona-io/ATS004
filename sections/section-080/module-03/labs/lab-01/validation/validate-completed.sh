#!/usr/bin/env bash
set -u

if ! grep -q '^42:/srv/xfs/webdata$' /etc/projects 2>/dev/null; then
  echo "FAIL: /etc/projects does not have '42:/srv/xfs/webdata'"
  exit 1
fi

if ! grep -q '^webdata:42$' /etc/projid 2>/dev/null; then
  echo "FAIL: /etc/projid does not have 'webdata:42'"
  exit 1
fi

user_report=$(sudo xfs_quota -x -c 'report -h' /srv/xfs 2>/dev/null)
alice_line=$(echo "$user_report" | grep -E '^alice\b')
if [ -z "$alice_line" ]; then
  echo "FAIL: no user quota report line for alice"
  echo "$user_report"
  exit 1
fi

if ! echo "$alice_line" | grep -qE '40M[[:space:]]+50M'; then
  echo "FAIL: alice's soft/hard limits are not 40M/50M"
  echo "$alice_line"
  exit 1
fi

project_report=$(sudo xfs_quota -x -c 'report -p -h' /srv/xfs 2>/dev/null)
webdata_line=$(echo "$project_report" | grep -E '^webdata\b')
if [ -z "$webdata_line" ]; then
  echo "FAIL: no project quota report line for webdata"
  echo "$project_report"
  exit 1
fi

if ! echo "$webdata_line" | grep -qE '100M'; then
  echo "FAIL: webdata project hard limit is not 100M"
  echo "$webdata_line"
  exit 1
fi

echo "PASS: alice's user quota (40M/50M) and the webdata project quota (100M) are both active"
exit 0
