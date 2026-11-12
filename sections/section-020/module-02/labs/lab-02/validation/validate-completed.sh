#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
set -u

fail() { echo "FAIL: $*"; exit 1; }

# Read the live fstab, ignoring comment lines.
fstab_lines=$(grep -vE '^[[:space:]]*#' /etc/fstab)

has_option() {
  # $1 = comma-separated options, $2 = option name (exact, or name=value prefix)
  echo "$1" | tr ',' '\n' | grep -qE "^$2(=.*)?$"
}

# --- NFS line ---
nfs_line=$(echo "$fstab_lines" | awk '$2=="/mnt/nfs-reports"')
[ -n "$nfs_line" ] || fail "no /etc/fstab line for /mnt/nfs-reports"
nfs_src=$(echo "$nfs_line" | awk '{print $1}')
nfs_type=$(echo "$nfs_line" | awk '{print $3}')
nfs_opts=$(echo "$nfs_line" | awk '{print $4}')
case "$nfs_src" in
  127.0.0.1:/srv/nfs/reports|localhost:/srv/nfs/reports) ;;
  *) fail "NFS fstab source is '$nfs_src', expected 127.0.0.1:/srv/nfs/reports" ;;
esac
case "$nfs_type" in nfs|nfs4) ;; *) fail "NFS fstab type is '$nfs_type', expected nfs" ;; esac
has_option "$nfs_opts" _netdev || fail "NFS fstab line has no _netdev option"
has_option "$nfs_opts" nofail  || fail "NFS fstab line has no nofail option"

# --- SSHFS line ---
ssh_line=$(echo "$fstab_lines" | awk '$2=="/mnt/sshfs-logs"')
[ -n "$ssh_line" ] || fail "no /etc/fstab line for /mnt/sshfs-logs"
ssh_src=$(echo "$ssh_line" | awk '{print $1}')
ssh_type=$(echo "$ssh_line" | awk '{print $3}')
ssh_opts=$(echo "$ssh_line" | awk '{print $4}')
case "$ssh_src" in
  sshuser@localhost:/opt/remote-data|sshuser@127.0.0.1:/opt/remote-data) ;;
  *) fail "SSHFS fstab source is '$ssh_src', expected sshuser@localhost:/opt/remote-data" ;;
esac
[ "$ssh_type" = "fuse.sshfs" ] || fail "SSHFS fstab type is '$ssh_type', expected fuse.sshfs"
has_option "$ssh_opts" _netdev       || fail "SSHFS fstab line has no _netdev option"
has_option "$ssh_opts" IdentityFile  || fail "SSHFS fstab line has no IdentityFile= option (root needs a key file)"

# Inspect the current mounts without repairing unfinished work.
mountpoint -q /mnt/nfs-reports || fail "/mnt/nfs-reports is not mounted"
mountpoint -q /mnt/sshfs-logs || fail "/mnt/sshfs-logs is not mounted"

nfs_fstype=$(findmnt -no FSTYPE /mnt/nfs-reports 2>/dev/null)
case "$nfs_fstype" in nfs|nfs4) ;; *) fail "after 'mount -a', /mnt/nfs-reports is not an NFS mount (found '$nfs_fstype'). Is the export fixed?" ;; esac
[ -f /mnt/nfs-reports/q4-report.txt ] || fail "q4-report.txt is not readable through /mnt/nfs-reports"
if touch /mnt/nfs-reports/probe-file >/dev/null 2>&1; then
  rm -f /mnt/nfs-reports/probe-file
  fail "writing to /mnt/nfs-reports works, but the share must be read-only"
fi

ssh_fstype=$(findmnt -no FSTYPE /mnt/sshfs-logs 2>/dev/null)
[ "$ssh_fstype" = "fuse.sshfs" ] || fail "after 'mount -a', /mnt/sshfs-logs is not a fuse.sshfs mount (found '$ssh_fstype')"
[ -f /mnt/sshfs-logs/welcome.txt ] || fail "welcome.txt is not readable through /mnt/sshfs-logs"

echo "PASS: the NFS export is fixed and both remote mounts come back from /etc/fstab"
exit 0
ASTRONA_STUDENT_SCRIPT
