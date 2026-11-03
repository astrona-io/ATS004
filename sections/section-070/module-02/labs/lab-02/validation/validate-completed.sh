#!/usr/bin/env bash
set -u

fail() { echo "FAIL: $*"; exit 1; }

# --- The holder PID was recorded, and the process is stopped ---
real_pid=$(sudo cat /var/lib/lab070202-holder.pid 2>/dev/null | tr -d '[:space:]')
[ -n "$real_pid" ] || fail "the grader could not read the holder PID (the setup did not finish)"

recorded=$(sudo cat /root/holder-pid.txt 2>/dev/null | tr -d '[:space:]')
[ -n "$recorded" ] || fail "/root/holder-pid.txt not found or empty -- record the PID of the process that holds the deleted file"
[ "$recorded" = "$real_pid" ] || fail "/root/holder-pid.txt says '$recorded', but the process holding the deleted file is not that PID"

if [ -d "/proc/$real_pid" ]; then
  fail "process $real_pid is still running and still holds the deleted file"
fi

# --- No deleted-but-open file is left on /mnt/spool, and the space is back ---
if ! command -v lsof >/dev/null 2>&1; then
  fail "lsof is not installed on this machine"
fi
leftover=$(sudo lsof +L1 /mnt/spool 2>/dev/null | grep -c '(deleted)')
[ "$leftover" = "0" ] || fail "a deleted file that is still open remains on /mnt/spool (lsof +L1 /mnt/spool)"

used_kb=$(df -k --output=used /mnt/spool 2>/dev/null | tail -1 | tr -d ' ')
if [ -z "$used_kb" ] || [ "$used_kb" -gt 100000 ]; then
  fail "/mnt/spool still uses ${used_kb:-unknown} KB; the hidden 300M file is not freed"
fi

# --- The scheduler rule ---
rule_file=$(grep -lE '^[[:space:]]*[^#].*ATTR\{queue/scheduler\}[[:space:]]*=[[:space:]]*"mq-deadline"' /etc/udev/rules.d/*.rules 2>/dev/null | head -1)
[ -n "$rule_file" ] || fail "no udev rule in /etc/udev/rules.d sets ATTR{queue/scheduler}=\"mq-deadline\""

disk=$(basename "$(readlink -f /dev/disk/by-id/virtio-lab070202-spool)")
current=$(cat "/sys/block/$disk/queue/scheduler" 2>/dev/null)
echo "$current" | grep -q '\[mq-deadline\]' || fail "the scheduler of $disk is not mq-deadline now (found: $current). Reload and trigger udev."

echo "PASS: the hidden space was freed after recording the holder, and a udev rule sets mq-deadline on the spool disk"
exit 0
