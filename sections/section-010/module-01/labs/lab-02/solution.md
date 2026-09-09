# Solution Walkthrough

This guide shows you how to find and safely evict a process that is
blocking an unmount.

---

## Step 1: Try to unmount, and see it fail

```bash
sudo umount /mnt/locked-vault
```

Expect something like:

```text
umount: /mnt/locked-vault: target is busy.
```

The kernel refuses because at least one process still has something open
on that filesystem — a working directory, an open file, or a mapped
executable. Forcing it (`umount -l`) would hide the problem, not fix it,
so the task is to find and stop the actual process first.

---

## Step 2: Find out who is holding it open

```bash
sudo lsof +D /mnt/locked-vault
```

or

```bash
sudo fuser -vm /mnt/locked-vault
```

Expect something like:

```text
COMMAND     PID USER   FD   TYPE DEVICE SIZE/OFF   NODE NAME
vault-keep  842 root  cwd    DIR  253,1     4096      2 /mnt/locked-vault
vault-keep  842 root    3w   REG  253,1       11      5 /mnt/locked-vault/.lockfile
```

The `vault-keeper` process (PID will vary) both has its working directory
inside the mount and an open file there — either one alone would be enough
to keep the mount busy.

---

## Step 3: Stop the process cleanly

Since it runs as a systemd unit, the cleanest stop is through systemd
itself (this sends a graceful `SIGTERM` and waits before escalating):

```bash
sudo systemctl stop vault-keeper.service
```

If you only had the bare PID from `lsof`/`fuser` and no service name, the
equivalent manual sequence is:

```bash
sudo kill 842        # SIGTERM: ask it to exit
sleep 2
ps -p 842             # still running?
sudo kill -9 842      # SIGKILL: force it, only if step above shows it's still alive
```

Do not run a blanket `pkill`/`killall` on a generic name — that risks
taking down unrelated processes that happen to share part of the name.

---

## Step 4: Unmount again

```bash
sudo umount /mnt/locked-vault
findmnt /mnt/locked-vault
```

Expect something like:

```text
(no output from findmnt — nothing is mounted there anymore)
```

With the last process gone, the kernel's reference count on the mount
drops to zero and the unmount succeeds cleanly.
