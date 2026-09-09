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

## How this module is organised

1. **[Part 1 — How On-Demand Mounting Works, and Enabling autofs](./course-01-mechanism-and-enabling.md)** — the kernel-trap-and-resume mechanism behind a trigger mountpoint, and starting the `autofs` service.
2. **[Part 2 — The Master Map, Triggering & Idle Unmount](./course-02-master-map-and-triggering.md)** — `/etc/auto.master` syntax, direct vs indirect maps and their precedence, triggering a mount live, and the idle-timeout unmount.

## Learning objectives

After this module you can:

- Explain the kernel trap-and-resume mechanism `autofs` uses to intercept access to a managed directory and mount on demand, with no polling involved.
- Enable and check the `autofs` service.
- Write an `/etc/auto.master` entry that puts a directory under `autofs` control with an idle timeout.
- Distinguish an indirect map from a direct map, and state which one wins if both could claim the same path.
- Apply map changes with `systemctl reload autofs` and see the trigger zone in `mount`.

## Before you start

You should know how to mount and unmount a filesystem, edit a config file with `sudo`, and manage a service with `systemctl`.

The linked playground gives you an Ubuntu server VM with `autofs` installed (service not yet started), a local directory `/srv/localdata` with a couple of files, and `/etc/auto.master` backed up to `/etc/auto.master.orig`. The examples map `/srv/localdata` through `autofs` as a local bind mount, so you can see the trigger-and-timeout behaviour without any NFS server. Run the command blocks in Parts 1–2 in that VM after `astrona ssh section-050-module-01-playground`.
