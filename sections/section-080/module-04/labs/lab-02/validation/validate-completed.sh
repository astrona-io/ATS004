#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Inspect protected state; user access checks select their target account explicitly.
sudo -n bash <<'GRADER_ROOT'
set -u

fail() { echo "FAIL: $*"; exit 1; }

# --- Files are in their FHS places, and were moved, not copied ---
[ -f /etc/acme/acme.conf ]            || fail "/etc/acme/acme.conf is missing (configuration belongs in /etc)"
[ -f /usr/local/bin/acme-report ]     || fail "/usr/local/bin/acme-report is missing (a locally added program belongs in /usr/local/bin)"
[ -x /usr/local/bin/acme-report ]     || fail "/usr/local/bin/acme-report is not executable"
[ -f /var/log/acme/acme.log ]         || fail "/var/log/acme/acme.log is missing (logs belong in /var/log)"
[ -f /var/lib/acme/inventory.db ]     || fail "/var/lib/acme/inventory.db is missing (changing program data belongs in /var/lib)"

for name in acme.conf acme-report acme.log inventory.db; do
  [ ! -e "/srv/staging/$name" ] || fail "/srv/staging/$name is still there -- move the file, do not copy it"
done

grep -q "listen_port = 8080" /etc/acme/acme.conf || fail "/etc/acme/acme.conf lost its content"

# --- Hard link: same inode as the configuration file ---
keep=/var/lib/acme/acme.conf.keep
[ -e "$keep" ] || fail "$keep does not exist"
[ ! -L "$keep" ] || fail "$keep is a symbolic link, but a hard link was asked for"
[ "$(stat -c %i "$keep")" = "$(stat -c %i /etc/acme/acme.conf)" ] || fail "$keep is not a hard link to /etc/acme/acme.conf (different inode)"
[ "$(stat -c %h /etc/acme/acme.conf)" -ge 2 ] || fail "/etc/acme/acme.conf has a link count below 2"

# --- Symbolic link 1: a short command name ---
[ -L /usr/local/bin/acme ] || fail "/usr/local/bin/acme is not a symbolic link"
[ "$(readlink -f /usr/local/bin/acme)" = "/usr/local/bin/acme-report" ] || fail "/usr/local/bin/acme does not resolve to /usr/local/bin/acme-report"
[ "$(/usr/local/bin/acme 2>/dev/null)" = "acme report: all systems nominal" ] || fail "running /usr/local/bin/acme does not print the report"

# --- Symbolic link 2: current log ---
[ -L /var/lib/acme/current.log ] || fail "/var/lib/acme/current.log is not a symbolic link"
[ "$(readlink -f /var/lib/acme/current.log)" = "/var/log/acme/acme.log" ] || fail "/var/lib/acme/current.log does not resolve to /var/log/acme/acme.log"

echo "PASS: files are in their FHS places, the hard link shares an inode, and both symbolic links resolve"
exit 0
GRADER_ROOT
ASTRONA_STUDENT_SCRIPT
