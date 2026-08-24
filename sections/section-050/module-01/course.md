# On-Demand Mounting Fundamentals

Mounting remote network shares directly in `/etc/fstab` is dangerous. When a Linux server boots, it reads `fstab` and attempts to mount every filesystem listed. If an NFS server is offline or a network switch is rebooting, the client server will hang indefinitely during the boot sequence, waiting for a network reply that isn't coming. Even if it boots successfully, an idle network mount held open forever consumes resources and risks freezing applications if the connection drops later.

You solve this by switching to on-demand mounting using `autofs`.

Think of `autofs` as a dynamic on-demand retrieval courier at a massive library archive. The courier doesn't go pull thousands of books and pile them on the front desk every morning just in case someone asks for them. Instead, the courier waits empty-handed at the desk. The exact millisecond you ask for a specific book, the courier sprints to the back, grabs it, and hands it to you. When you walk away and leave the book idle on the table for ten minutes, the courier quietly puts it back in the archive.

## VFS Interception and the Autofs Daemon

`autofs` works by intercepting requests at the Virtual File System (VFS) layer. It sits entirely in the background, governed by a systemd daemon.

```bash
systemctl enable --now autofs
```

Once running, `autofs` stakes a claim on specific, empty directories on your local machine. If a user runs `cd` into one of those directories, or an application tries to `ls` it, the kernel pauses the request. It flags `autofs` that someone just knocked on the door. `autofs` immediately reads its configuration map, executes the actual `mount` command in the background, and then tells the kernel to resume the user's command. The user never knows the mount wasn't there a second ago.

## The Master Map: /etc/auto.master

The rules governing which directories `autofs` monitors are defined in the master map: `/etc/auto.master`.

This file maps a base directory (the trigger zone) to a secondary configuration file that contains the specific mount instructions.

A standard entry looks like this:

```text
/net-data    /etc/auto.netdata    --timeout=600
```

This line tells `autofs` three things:
1. **The Mount Point:** Watch the `/net-data` directory. This is an indirect mount. `autofs` now owns this directory.
2. **The Map File:** If someone requests something inside `/net-data`, look inside the `/etc/auto.netdata` file to figure out what to do.
3. **The Options:** Pass specific options to the daemon managing this zone. The `--timeout=600` flag is critical. It tells `autofs` that if a mounted share sits completely idle with no open files for 600 seconds (10 minutes), unmount it automatically to save resources and prevent stale network locks.

After modifying `/etc/auto.master` or any of its map files, you must reload the service to apply the changes.

```bash
systemctl reload autofs
```

## Self-Check and Verification

To prove you understand autofs fundamentals:

1. Install the `autofs` package and verify the service is running using `systemctl status autofs`.
2. Edit `/etc/auto.master` to add a new watch directory pointing to a custom map file, including a short timeout (e.g., `--timeout=60`).
3. Reload the `autofs` daemon.
4. Run `mount | grep autofs` and verify the kernel recognizes the new trigger zone.
