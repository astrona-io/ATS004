#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -u

fail() { echo "FAIL: $*"; exit 1; }

# --- ext4: bob and carol have alice's limits (40M soft, 50M hard) ---
user_report=$(sudo repquota -s /quota-ext 2>/dev/null)
[ -n "$user_report" ] || fail "repquota could not report on /quota-ext (are user quotas on?)"

for user in alice bob carol; do
  line=$(echo "$user_report" | grep -E "^$user\b")
  [ -n "$line" ] || fail "no quota entry for $user on /quota-ext"
  # Match soft immediately followed by hard, not a fixed column.
  echo "$line" | grep -Pq '\b40M\s+50M\b' || fail "$user's block limits are not 40M soft / 50M hard: $line"
done

# --- XFS: group engineers has 50M soft / 80M hard ---
group_report=$(sudo xfs_quota -x -c 'report -g -b -h' /srv/xfs-teams 2>/dev/null)
eng_line=$(echo "$group_report" | grep -E '^engineers\b')
[ -n "$eng_line" ] || fail "no group quota line for engineers on /srv/xfs-teams"
echo "$eng_line" | grep -Eq '50M[[:space:]]+80M' || fail "engineers' block limits are not 50M soft / 80M hard: $eng_line"

# --- XFS: the group block grace timer is 3 days ---
state=$(sudo xfs_quota -x -c 'state -g' /srv/xfs-teams 2>/dev/null)
echo "$state" | grep -Eq 'Blocks grace time: *\[(3 days|72:00:00)' || \
  fail "the group block grace time on /srv/xfs-teams is not 3 days: $(echo "$state" | grep -i 'Blocks grace time')"

echo "PASS: alice's limits were copied to bob and carol, and engineers has 50M/80M with a 3-day block timer on XFS"
exit 0
ASTRONA_STUDENT_SCRIPT
