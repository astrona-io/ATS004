# /etc/fstab in Depth

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-010/module-05/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-010/module-05/playground
> astrona destroy section-010-module-05-playground
> ```

A `mount` command lasts until reboot. To have a filesystem come back automatically every boot, you describe it in `/etc/fstab` — the filesystem table. The kernel and systemd read this file early in startup and mount everything it lists.

`/etc/fstab` is also where a small mistake stops a server from booting into a normal state. This module covers the six fields of an entry, which identifier to use for the device, the options that matter, and how to check an entry is safe *before* you rely on it at boot.

## How this module is organised

1. **[Part 1 — fstab Fields & Stable Identifiers](./course-01-fields-and-stable-identifiers.md)** — the six fields of an entry, and why `UUID=` beats a `/dev/` path.
2. **[Part 2 — Options & Verifying Before You Trust It](./course-02-options-and-verifying.md)** — `nofail`/`_netdev`/`noatime` and what they change at boot, plus `findmnt --verify` and `mount -a` as the pre-reboot safety check.

## Learning objectives

After this module you can:

- Name the six fields of an `/etc/fstab` line and what each controls.
- Choose `UUID=` / `LABEL=` / `PARTUUID=` over a `/dev/sdX` path and say why.
- Pick sensible mount options, including when to add `nofail` and `_netdev`, and explain what each changes about boot ordering.
- Set the `dump` and `pass` fields correctly for a data filesystem, the root filesystem, and swap.
- Test an entry with `sudo mount -a` and `findmnt --verify` before trusting it at boot.

## Before you start

You should know how to mount a filesystem manually (`mount`, `umount`) and read `blkid` / `lsblk` output.

The linked playground gives you an Ubuntu server VM with two spare 1 GB ext4 filesystems (labels `DATA1`, `DATA2`, commonly `/dev/vdb` and `/dev/vdc` — run `sudo blkid` to see which is which), `/etc/fstab` backed up to `/etc/fstab.orig`, and passwordless `sudo`. Editing `/etc/fstab` in the VM is safe — it is a throwaway machine and the backup restores it. Run the command blocks in Parts 1–2 in that VM after `astrona ssh astro-section-010-module-05-playground`.
