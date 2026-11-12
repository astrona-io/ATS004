#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
set -u

quota_state=$(sudo quotaon -p /quota 2>/dev/null)
if ! echo "$quota_state" | grep -q "user quota on /quota .* is on"; then
  echo "FAIL: user quota is not enabled on /quota"
  echo "$quota_state"
  exit 1
fi
if ! echo "$quota_state" | grep -q "group quota on /quota .* is on"; then
  echo "FAIL: group quota is not enabled on /quota"
  echo "$quota_state"
  exit 1
fi

user_report=$(sudo repquota -v /quota 2>/dev/null)

# Read limits in KiB; human-readable units vary with quota-tools versions.
alice_line=$(echo "$user_report" | grep -E '^alice\b')
if [ -z "$alice_line" ]; then
  echo "FAIL: no quota entry found for alice"
  echo "$user_report"
  exit 1
fi
if ! echo "$alice_line" | awk '$4 == 40960 && $5 == 51200 {ok=1} END {exit !ok}'; then
  echo "FAIL: alice's block quota is not soft=40M hard=50M"
  echo "$alice_line"
  exit 1
fi

bob_line=$(echo "$user_report" | grep -E '^bob\b')
if [ -z "$bob_line" ]; then
  echo "FAIL: no quota entry found for bob"
  echo "$user_report"
  exit 1
fi
if ! echo "$bob_line" | awk '$4 == 20480 && $5 == 30720 {ok=1} END {exit !ok}'; then
  echo "FAIL: bob's block quota is not soft=20M hard=30M"
  echo "$bob_line"
  exit 1
fi

group_report=$(sudo repquota -vg /quota 2>/dev/null)
team_line=$(echo "$group_report" | grep -E '^team\b')
if [ -z "$team_line" ]; then
  echo "FAIL: no quota entry found for group team"
  echo "$group_report"
  exit 1
fi
if ! echo "$team_line" | awk '$4 == 102400 && $5 == 122880 {ok=1} END {exit !ok}'; then
  echo "FAIL: team's block quota is not soft=100M hard=120M"
  echo "$team_line"
  exit 1
fi

echo "PASS: ext4 user and group quotas enabled with correct limits"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
