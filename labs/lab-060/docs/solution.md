# Solution

## Step 1: Read total and available memory straight from the kernel

Check `man 5 proc` — search for the `/proc/meminfo` subsection, which documents `MemTotal`, `MemFree`, and `MemAvailable` as the key fields (note `MemAvailable` is the more useful "how much can I actually allocate" figure, not `MemFree`).

```bash
cat /proc/meminfo | head -5
```

Example output:

```
MemTotal:       16384000 kB
MemFree:         2048000 kB
MemAvailable:    6144000 kB
Buffers:          128000 kB
Cached:          3072000 kB
```

Every value here is generated at the instant you run `cat` — there is no on-disk copy anywhere; run the command again a moment later and the numbers will already have shifted. Tools like `free -h` are simply friendlier formatters wrapped around this exact same file.

## Step 2: Count a process's open file descriptors

```bash
PID=$(cat /opt/course/target.pid)
ls /proc/$PID/fd | wc -l
```

Check `man 5 proc` — the `/proc/[pid]/fd/` subsection explains each entry is a symlink named by its file descriptor number, pointing at whatever that descriptor references (regular file, socket, pipe, device). `ls` simply lists the symlink names; piping to `wc -l` counts them, giving you "how many file descriptors this process currently has open."

To see what each one actually points at, not just the count:

```bash
sudo ls -l /proc/$PID/fd
```

This is genuinely useful troubleshooting beyond the lab exercise — a process leaking file descriptors (never closing files/sockets) shows a steadily growing list here over time.

## Step 3: Read the current IP forwarding state, then change it temporarily

```bash
cat /proc/sys/net/ipv4/ip_forward
```

`0` means disabled, `1` means enabled. Check `man 5 proc` — the `/proc/sys/` subsection explains that this directory tree mirrors kernel tunables one-to-one, and that most entries here accept a plain write to change the live value immediately.

```bash
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
cat /proc/sys/net/ipv4/ip_forward
```

This takes effect immediately — the kernel now forwards IPv4 packets between interfaces — but it is **not** persisted anywhere; a reboot reverts it to whatever the boot-time default/config specifies. Do **not** also write a file under `/etc/sysctl.d/` here — the task explicitly asks for a temporary, current-boot-only change.

## Step 4: Show the sysctl-equivalent variable name

```bash
sysctl net.ipv4.ip_forward
```

Expected output:

```
net.ipv4.ip_forward = 1
```

The translation rule is entirely mechanical: strip the `/proc/sys/` prefix from the path, then replace every remaining `/` with a `.` — `/proc/sys/net/ipv4/ip_forward` becomes `net.ipv4.ip_forward`. This works for essentially every tunable under `/proc/sys`, which is why memorizing the rule is more useful than memorizing individual variable names.

## Step 5: Read the live mount table directly for `/`

Check `man 5 proc` — search for `/proc/mounts` and `/proc/[pid]/mountinfo`; the page notes `/proc/mounts` gives the classic `mtab`-style format while `/proc/self/mountinfo` gives a richer, more detailed format including propagation and mount ID information.

```bash
grep ' / ' /proc/mounts
```

Example output:

```
/dev/vda1 / ext4 rw,relatime 0 0
```

Fields, in order: device source, mount point, filesystem type, mount options, and two legacy dump/pass fields (unused/always `0` here). Compare against the higher-level tools:

```bash
findmnt /
mount | grep ' on / '
```

All three ultimately reflect the same kernel-internal mount table — `/proc/mounts` is simply the rawest, most direct read of it, generated fresh on every access with zero possibility of drifting from reality, which is why it's the tiebreaker source of truth if `mount`'s own output is ever in question (historically due to `/etc/mtab` staleness, though modern distros avoid that by symlinking `/etc/mtab` to `/proc/self/mounts`).

## Step 6: Tour the rest of procfs's most useful files

Beyond the specific facts the scenario asked for, a handful of other procfs entries come up constantly enough to be worth touring now rather than discovering under exam pressure:

```bash
cat /proc/cpuinfo | grep -E 'model name|processor' | head -4
cat /proc/uptime
cat /proc/loadavg
cat /proc/version
```

Check `man 5 proc` for each of these by name — `/proc/cpuinfo` lists one stanza per logical CPU (so `grep processor` counts them); `/proc/uptime` is two numbers, seconds since boot and total idle time summed across CPUs; `/proc/loadavg` is the same three averages `uptime`/`w` display, plus a runnable/total-process count and the last PID allocated; `/proc/version` is the same string `uname -a` derives from.

Per-process, three more are worth knowing beyond `/proc/<PID>/fd`:

```bash
cat /proc/$PID/status | head -5
cat /proc/$PID/cmdline | tr '\0' ' '; echo
sudo cat /proc/$PID/environ | tr '\0' '\n'
```

`/proc/<PID>/status` gives a human-readable summary (state, memory, UID/GID) of the same data `ps` and `top` format for display. `/proc/<PID>/cmdline` holds the exact argv the process was launched with, NUL-separated rather than space-separated — `tr '\0' ' '` makes it readable, and the raw NUL-separation is precisely why a naive `cat` looks like one run-together word. `/proc/<PID>/environ` is that process's environment at launch time, also NUL-separated, and requires `sudo` to read for a process you don't own since it can contain secrets.

## Verification

```bash
cat /proc/meminfo | grep -E 'MemTotal|MemAvailable'
# expect: two lines with live kB values

ls /proc/$PID/fd | wc -l
# expect: a positive integer matching the process's actual open FD count

cat /proc/sys/net/ipv4/ip_forward
# expect: 1 (after the change)

sysctl net.ipv4.ip_forward
# expect: net.ipv4.ip_forward = 1

grep ' / ' /proc/mounts
# expect: line showing device, /, fstype, and options for the root filesystem
```

## Command Summary

```bash
cat /proc/meminfo | head -5
PID=$(cat /opt/course/target.pid)
ls /proc/$PID/fd | wc -l
sudo ls -l /proc/$PID/fd
cat /proc/sys/net/ipv4/ip_forward
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
sysctl net.ipv4.ip_forward
grep ' / ' /proc/mounts
findmnt /
```
