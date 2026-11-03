# Drop-In Master Files and Debugging autofs

Real ships rarely edit one big master file. Ubuntu lets you drop one small file per job into a folder. And when the robot does nothing, you need a way to ask it what it sees. This part covers both.

## Drop-in files in /etc/auto.master.d/

On Ubuntu, `/etc/auto.master` ends with lines that start with `+`. The line `+dir:/etc/auto.master.d` tells `autofs` to read every file ending in `.autofs` from that folder as if its lines were in the master map. Each job gets its own file, so one job can be added or removed without touching the others.

<!-- astrona:playground:renew -->

### See it in your playground

Check that your master map includes the folder:

```sh
grep -n '^+' /etc/auto.master
```

The output lists the lines that start with `+`, and one of them names `/etc/auto.master.d`. Now build the same indirect map as before, but as a drop-in. Save this as `/etc/auto.master.d/demo.autofs` (a file under `/etc` is saved with `sudo`):

```text
/mnt/auto  /etc/auto.demo  --timeout=15
```

Save this as `/etc/auto.demo`:

```text
data  -fstype=bind  :/srv/localdata
```

Apply it, then check the result:

```sh
sudo systemctl reload autofs
mount | grep /mnt/auto
ls /mnt/auto/data
```

`mount` shows the `autofs` trigger on `/mnt/auto`, and the `ls` triggers the bind mount, exactly as if the line had been in `/etc/auto.master`. If you already have the same managed directory in two places, `autofs` uses the first one it reads and ignores the other. Keep a managed directory in one file only.

## Asking the daemon what it sees

When a path does not mount, the first question is what the daemon actually loaded. Run `automount -m`. It prints the master map and every map it read, with the mount points and keys. If your entry is missing from that output, the daemon never saw it, and the problem is the master map or a missing reload.

The second tool is the foreground debug run. Stop the service, run the daemon in your terminal with `-f` (foreground) and `-v` (verbose), and read what it says as you trigger a path from a second shell. Press Ctrl+C to stop it, then start the service again.

### See it in your playground

Dump what the daemon loaded:

```sh
sudo automount -m
```

The output lists each managed directory with its map file, and the key `data` with its bind-mount target. Read the service log as well:

```sh
journalctl -u autofs --no-pager | tail -n 20
```

The log shows the daemon's start-up lines and any map errors. When you need the live view, use the foreground run:

```sh
sudo systemctl stop autofs
sudo automount -f -v
```

Leave it running, open a second shell with `astrona ssh section-050-module-01-playground`, and run `ls /mnt/auto/data`. The first shell prints the lookup and the mount as they happen. Stop the daemon with Ctrl+C, then start the service again:

```sh
sudo systemctl start autofs
```

## Common pitfalls

> [!WARNING]
> - **A drop-in without the `.autofs` ending.** `autofs` reads only files with that ending from the folder.
> - **The same managed directory in two files.** Only the first is used. Keep one file per directory.
> - **Debugging with the service still running.** The foreground daemon and the service fight over the same triggers. Stop the service first.
> - **Forgetting to start the service after the debug run.** With the service stopped, nothing is managed. Run `sudo systemctl start autofs`.
> - **Reading old log lines.** Use `tail` and compare the time to your last test.
