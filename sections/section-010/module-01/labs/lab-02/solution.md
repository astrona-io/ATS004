# Solution Walkthrough

Find the crew member inside the hold, ask them to leave, and only then undock. Each step below proves one thing before you move to the next, and the last step checks the machine the same way the grader does.

---

## Step 1: Try to unmount, and see it fail

```sh
sudo umount /mnt/locked-vault
```

Expect something like:

```text
umount: /mnt/locked-vault: target is busy.
```

The kernel refuses because at least one process still points into that filesystem: a working directory, an open file or a running program. Forcing it with `umount -l` would hide the problem, not fix it. The task is to find and stop the real process first.

---

## Step 2: Find out who is holding it open

Ask `lsof` which processes have something open under the mount:

```sh
sudo lsof +D /mnt/locked-vault
```

Expect something like:

```text
COMMAND     PID USER   FD   TYPE DEVICE SIZE/OFF   NODE NAME
vault-keep  842 root  cwd    DIR  253,1     4096      2 /mnt/locked-vault
vault-keep  842 root    3w   REG  253,1       11      5 /mnt/locked-vault/.lockfile
```

Your PID and `DEVICE` numbers will differ, and `lsof` may cut the command name to `vault-kee`.

The `vault-keeper` process has its working directory (`cwd`) inside the mount and also holds a file open for writing (`3w`, the `.lockfile`). Either one alone is enough to keep the mount busy.

You can get the same answer from `fuser`:

```sh
sudo fuser -vm /mnt/locked-vault
```

Look for a line with the `vault-keeper` command and its PID. The `ACCESS` column should contain `c` (its current directory is here) and `F` or `f` (it has a file open here).

---

## Step 3: Find out what started the process

Before you stop it, check whether a service manages it. Use the PID you found (here `842`):

```sh
systemctl status 842
```

Look at the first line of the output: it names the unit that owns the process, `vault-keeper.service`. Because systemd (the ship's duty officer) started it, systemd is also the cleanest way to stop it.

---

## Step 4: Stop the process cleanly

Stop the service through systemd. This sends a graceful `SIGTERM` first and waits before it climbs to anything stronger:

```sh
sudo systemctl stop vault-keeper.service
```

If you only had the bare PID from `lsof` or `fuser` and no service name, the same idea by hand looks like this:

```sh
sudo kill 842        # SIGTERM: ask it to exit
sleep 2
ps -p 842             # still running?
sudo kill -9 842      # SIGKILL: force it, only if step above shows it's still alive
```

Replace `842` with your own PID. Run the `kill -9` line only if `ps -p` still lists the process.

Do not run a blanket `pkill` or `killall` on a generic name. That risks stopping other processes whose names share part of the text, and the grader fails the task if `sshd` stops.

---

## Step 5: Unmount again

```sh
sudo umount /mnt/locked-vault
findmnt /mnt/locked-vault
```

`umount` prints nothing when it works, and `findmnt` prints nothing because nothing is mounted at `/mnt/locked-vault` any more. With the last process gone, the kernel's count of references on the mount dropped to zero, so the unmount succeeded.

---

## Step 6: Check your work and submit

Check the three things the grader checks:

```sh
pgrep -f /usr/local/bin/vault-keeper
findmnt /mnt/locked-vault
pgrep -x sshd
```

- The first `pgrep` should print nothing: `vault-keeper` is no longer running.
- `findmnt` should print nothing: `/mnt/locked-vault` is unmounted.
- `pgrep -x sshd` should print at least one PID: the SSH service you are connected through is still running.

When all three look right, send it for grading:

```sh
astrona submit -c sections/section-010/module-01/labs/lab-02
```
