# On-Demand Mounting Fundamentals

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-050/module-01/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-050/module-01/playground
> astrona destroy section-050-module-01-playground
> ```

Listing a network share in `/etc/fstab` means the machine tries to mount it at every boot. If the storage server is down or the network is flaky at that moment, the boot can stall waiting for a reply. And a network mount that is held open around the clock ties up resources and can freeze applications if the link later drops.

`autofs` avoids both problems by mounting a filesystem only when something actually reaches for it, and unmounting it again after a set idle period. This module covers how that interception works and how the master map, `/etc/auto.master`, declares which directories `autofs` manages.

## Learning objectives

After this module you can:

- Explain how `autofs` intercepts access to a managed directory and mounts on demand.
- Enable and check the `autofs` service.
- Write an `/etc/auto.master` entry that puts a directory under `autofs` control with an idle timeout.
- Distinguish an indirect map from a direct map.
- Apply map changes with `systemctl reload autofs` and see the trigger zone in `mount`.

## Before you start

You should know how to mount and unmount a filesystem, edit a config file with `sudo`, and manage a service with `systemctl`.

The linked playground gives you an Ubuntu server VM with `autofs` installed (service not yet started), a local directory `/srv/localdata` with a couple of files, and `/etc/auto.master` backed up to `/etc/auto.master.orig`. The examples map `/srv/localdata` through `autofs` as a local bind mount, so you can see the trigger-and-timeout behaviour without any NFS server. Run the command blocks below in that VM after `astrona ssh section-050-module-01-playground`.

## How on-demand mounting works

> As an analogy: `autofs` is a retrieval clerk at a closed-stacks library. Nothing is on the reading tables by default. Ask for a specific book and the clerk fetches it in the moment; leave it untouched for a while and the clerk reshelves it. The analogy breaks down because `autofs` fetches and reshelves with no visible delay or action — the directory simply is or is not mounted.

Concretely: `autofs` is a daemon that "owns" certain local directories. When a process runs `cd` or `ls` on a path `autofs` manages and the mount is not currently present, the kernel pauses that request and signals `autofs`. The daemon reads its map, runs the real `mount`, and lets the kernel resume the request — which now sees a mounted filesystem. After the configured idle time with nothing open, `autofs` unmounts it.

## Enabling the service

`autofs` runs as a systemd service. `enable --now` both starts it and sets it to start at boot.

> [!TIP]
> **Try it — start autofs**
>
> ```sh
> sudo systemctl enable --now autofs
> systemctl status autofs --no-pager
> ```
>
> Expect something like:
>
> ```text
> ● autofs.service - Automounts filesystems on demand
>      Loaded: loaded (/lib/systemd/system/autofs.service; enabled; ...)
>      Active: active (running) since ...
> ```
>
> `Active: active (running)` and `enabled` mean the daemon is up and will return after a reboot. It is not managing anything yet — that comes from the maps.

## The master map: `/etc/auto.master`

`/etc/auto.master` lists which directories `autofs` controls. Each line has three parts:

```text
/mnt/auto    /etc/auto.demo    --timeout=15
```

1. **The managed directory** — `/mnt/auto`. `autofs` takes ownership of it. This form, where request*s* land on *keys underneath* the directory, is an **indirect map**.
2. **The map file** — `/etc/auto.demo`. When something is requested inside `/mnt/auto`, `autofs` looks here for what to mount. (The next module covers the map-file syntax.)
3. **Options** — here `--timeout=15` means "unmount anything under this directory after 15 seconds with no open files". Real deployments use longer values such as `--timeout=300` or `600`; 15 is short so you can watch the unmount happen.

The alternative is a **direct map**, written with `/-` as the managed "directory" and absolute paths as the keys in the map file. Direct maps suit a handful of fixed mount points scattered around the tree; indirect maps suit many siblings under one parent. Indirect is the common case.

The map file for this example holds one entry — a local bind mount of `/srv/localdata`:

```text
data    -fstype=bind    :/srv/localdata
```

After any change to `/etc/auto.master` or a map file, reload the service.

> [!TIP]
> **Try it — put a directory under autofs control**
>
> ```sh
> echo '/mnt/auto  /etc/auto.demo  --timeout=15' | sudo tee -a /etc/auto.master
> echo 'data  -fstype=bind  :/srv/localdata' | sudo tee /etc/auto.demo
> sudo systemctl reload autofs
> mount | grep autofs
> ls /mnt/auto
> ```
>
> Expect something like:
>
> ```text
> /etc/auto.demo on /mnt/auto type autofs (rw,relatime,fd=7,pgrp=...,timeout=15,...)
>
> (ls /mnt/auto prints nothing)
> ```
>
> `mount` shows `/mnt/auto` as type `autofs` — the trigger zone is active. `ls /mnt/auto` is empty because nothing has been requested yet; `autofs` creates the `data` subdirectory only when someone asks for it.

## Triggering a mount

The mount happens the instant a process references a key under the managed directory. Nothing special is needed — `ls`, `cd`, or opening a file all count.

> [!TIP]
> **Try it — reach for the key and watch it mount**
>
> ```sh
> ls /mnt/auto/data
> cat /mnt/auto/data/hello.txt
> mount | grep /mnt/auto
> ```
>
> Expect something like:
>
> ```text
> hello.txt  notes.txt
> hello from the on-demand bind mount
>
> /etc/auto.demo on /mnt/auto type autofs (...)
> /srv/localdata on /mnt/auto/data type none (rw,relatime,bind)
> ```
>
> The `ls` triggered `autofs`: `/mnt/auto/data` now exists and shows the files from `/srv/localdata`, and `mount` lists a second line — the actual bind mount that `autofs` created on demand.

## The idle unmount

Once nothing is reading from the mount and no shell is sitting in it, `autofs` unmounts it after the timeout. The trigger zone stays; only the on-demand mount underneath goes away.

> [!TIP]
> **Try it — let it time out**
>
> ```sh
> cd ~
> sleep 20
> mount | grep /mnt/auto
> ```
>
> Expect something like:
>
> ```text
> /etc/auto.demo on /mnt/auto type autofs (...)
> ```
>
> After ~15 seconds idle, the `bind` line is gone — only the `autofs` trigger line remains. The next `ls /mnt/auto/data` would mount it again. Make sure you `cd` out of `/mnt/auto/data` first; a shell inside it keeps the mount busy and the timeout never fires.

> [!WARNING]
> **Common pitfalls**
>
> - **Creating the managed directory's sub-entries by hand.** `mkdir /mnt/auto/data` makes the path exist as a normal empty folder, so the kernel never raises the "not found" that `autofs` needs. `autofs` creates and removes those subdirectories itself.
> - **Editing a map and expecting it to take effect.** `autofs` does not watch the files. Run `sudo systemctl reload autofs` after any change to `/etc/auto.master` or a map file.
> - **A shell sitting in the mount.** If your working directory is under the on-demand mount, it counts as in use and the idle timeout will not unmount it. `cd` out first.
> - **Confusing the `autofs` line with the real mount.** `mount` shows the trigger zone (type `autofs`) at all times and the actual filesystem (type `nfs`, `bind`, …) only while it is active. Grep for the real type to check whether something is mounted right now.
> - **Very short timeouts in production.** Frequent unmount/remount churn adds latency and log noise. Short values like `15` are for learning; pick minutes for real use.
