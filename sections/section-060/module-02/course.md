# The Hardware Tree & Runtime Tuning: /sys & sysctl

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-060/module-02/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-060/module-02/playground
> astrona destroy section-060-module-02-playground
> ```

`/proc` (previous module) leans toward processes. `/sys` is the same idea aimed at hardware: a kernel-generated tree of every bus, device, and driver, with each attribute exposed as a small file you can read. And under `/proc/sys/` sit the kernel's tunable parameters — files you can *write* to change kernel behaviour immediately, no reboot.

## How this module is organised

1. **[Part 1 — The Hardware Tree & the Mount List](./course-01-hardware-tree-and-mount-list.md)** — the kobject/`show`/`store` mechanism behind `/sys`, reading device attributes, and why `/proc/mounts` is the authoritative mount list.
2. **[Part 2 — sysctl: Viewing, Changing & Persisting](./course-02-sysctl-viewing-changing-persisting.md)** — `sysctl` as a name mapping onto `/proc/sys/`, why the `sudo echo >` pattern fails, and the exact precedence rule that decides which `sysctl.d` file wins.

## Learning objectives

After this module you can:

- Read a device attribute (such as a disk's sector size) from `/sys/class/...`, and explain the `show`/`store` mechanism that makes some `/sys` files read-only and others controls.
- Explain why `/proc/mounts` is the authoritative list of mounted filesystems, and what `/etc/mtab` actually is today.
- View a kernel parameter with `sysctl <name>` and map the dot-name to its `/proc/sys/` path.
- Change a parameter at runtime with `sysctl -w` (and know why `sudo echo 1 > ...` fails).
- Make a parameter change persist across reboots with a file in `/etc/sysctl.d/`.
- State the precedence order across `/etc/sysctl.d/`, `/run/sysctl.d/`, `/usr/lib/sysctl.d/`, and `/etc/sysctl.conf` when more than one file sets the same key.

## Before you start

You need the previous module's idea of a pseudo-filesystem — files whose contents the kernel generates on demand. Basic `cat`/`grep` and `sudo` are assumed.

The linked playground gives you an Ubuntu server VM with a 1 GB spare disk (commonly `/dev/vdb`) so `/sys` reads target a non-root device, and passwordless `sudo` for the writes. `bootstrap/prepare.sh` prints the starting root filesystem type and `ip_forward` value. Run the command blocks in Parts 1–2 in that VM after `astrona ssh section-060-module-02-playground`.
