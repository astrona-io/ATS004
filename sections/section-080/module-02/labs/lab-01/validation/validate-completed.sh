#!/usr/bin/env bash
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

user_report=$(sudo repquota -s /quota 2>/dev/null)

# Match soft immediately followed by hard on the user's line rather than a
# fixed column index -- repquota's leading status-flag column ("--", "+-",
# ...) shifts field positions across quota-tools versions/distros.
alice_line=$(echo "$user_report" | grep -E '^alice\b')
if [ -z "$alice_line" ]; then
  echo "FAIL: no quota entry found for alice"
  echo "$user_report"
  exit 1
fi
if ! echo "$alice_line" | grep -Pq '\b40M\s+50M\b'; then
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
if ! echo "$bob_line" | grep -Pq '\b20M\s+30M\b'; then
  echo "FAIL: bob's block quota is not soft=20M hard=30M"
  echo "$bob_line"
  exit 1
fi

group_report=$(sudo repquota -sg /quota 2>/dev/null)
team_line=$(echo "$group_report" | grep -E '^team\b')
if [ -z "$team_line" ]; then
  echo "FAIL: no quota entry found for group team"
  echo "$group_report"
  exit 1
fi
if ! echo "$team_line" | grep -Pq '\b100M\s+120M\b'; then
  echo "FAIL: team's block quota is not soft=100M hard=120M"
  echo "$team_line"
  exit 1
fi

echo "PASS: ext4 user and group quotas enabled with correct limits"
exit 0
