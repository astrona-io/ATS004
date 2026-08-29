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

This module covers reading device attributes from `/sys`, reading the authoritative mount list from `/proc/mounts`, and viewing and changing kernel parameters with `sysctl` — temporarily and then persistently.

## Learning objectives

After this module you can:

- Read a device attribute (such as a disk's sector size) from `/sys/class/...`.
- Explain why `/proc/mounts` is the authoritative list of mounted filesystems.
- View a kernel parameter with `sysctl <name>` and map the dot-name to its `/proc/sys/` path.
- Change a parameter at runtime with `sysctl -w` (and know why `sudo echo 1 > ...` fails).
- Make a parameter change persist across reboots with a file in `/etc/sysctl.d/`.

## Before you start

You need the previous module's idea of a pseudo-filesystem — files whose contents the kernel generates on demand. Basic `cat`/`grep` and `sudo` are assumed.

The linked playground gives you an Ubuntu server VM with a 1 GB spare disk (commonly `/dev/vdb`) so `/sys` reads target a non-root device, and passwordless `sudo` for the writes. `bootstrap/prepare.sh` prints the starting root filesystem type and `ip_forward` value. Run the command blocks below in that VM after `astrona ssh section-060-module-02-playground`.

## Reading the hardware tree: `/sys`

> As an analogy: `/sys` is a spec sheet for every part in the machine, kept current by the kernel. Want a disk's sector size? There is a file for it. The analogy breaks down because some `/sys` files are writable and act as controls (LED brightness, CPU governor, device power state), not just readouts.

`/sys` is organised by category. `/sys/class/block/<dev>/` holds block-device attributes; `/sys/class/net/<iface>/` holds network-interface attributes; `/sys/block/<dev>/queue/` holds I/O queue settings. Each leaf is a plain file.

> [!TIP]
> **Try it — read device attributes as files**
>
> ```sh
> lsblk -dn -o NAME,SIZE /dev/vdb
> cat /sys/class/block/vdb/queue/hw_sector_size
> cat /sys/class/block/vdb/size
> cat /sys/class/net/*/address
> ```
>
> Expect something like:
>
> ```text
> vdb    1G
> 512
> 2097152
> 00:00:00:00:00:00
> 52:54:00:a1:b2:c3
> ```
>
> `hw_sector_size` is the disk's physical sector size in bytes; `size` is its capacity in 512-byte sectors (2097152 × 512 = 1 GiB). The `address` files under `/sys/class/net/` are interface MAC addresses. No special utility — the kernel presents each fact as a readable file.

## The authoritative mount list: `/proc/mounts`

`/proc/mounts` (equivalently `/proc/self/mounts`) is the kernel's own list of mounted filesystems, generated when read. It is the source of truth: if a mount appears here, it is active now.

Historically `/etc/mtab` was a separate text file that user-space `mount`/`umount` kept updated, and it could drift from reality. On current systems `/etc/mtab` is just a symlink to `/proc/self/mounts`, and `mount` with no arguments and `findmnt` read the kernel's data directly. When in doubt, read `/proc/mounts`.

> [!TIP]
> **Try it — compare the views**
>
> ```sh
> ls -l /etc/mtab
> grep ' / ' /proc/mounts
> findmnt --noheadings --output SOURCE,TARGET,FSTYPE /
> ```
>
> Expect something like:
>
> ```text
> lrwxrwxrwx 1 root root 19 Aug 29 12:00 /etc/mtab -> /proc/self/mounts
>
> /dev/vda1 / ext4 rw,relatime 0 0
>
> /dev/vda1 / ext4
> ```
>
> `/etc/mtab` points straight at `/proc/self/mounts`, so there is no separate file to fall out of sync. The root line from `/proc/mounts` shows the device, mount point, filesystem type, and options exactly as the kernel has them.

## Viewing and changing kernel parameters: `sysctl`

The files under `/proc/sys/` are live kernel parameters. `sysctl` is the standard front end: it maps each file path to a dot-separated name, so `/proc/sys/net/ipv4/ip_forward` becomes `net.ipv4.ip_forward`. Reading is `sysctl <name>`; writing is `sysctl -w <name>=<value>`.

A concrete one: `net.ipv4.ip_forward` controls whether the kernel forwards IP packets between interfaces (acts as a router). It is `0` by default.

You cannot write these with `sudo echo 1 > /proc/sys/...` — the shell opens the redirect as your normal user *before* `sudo` runs, so the write is denied. Use `sysctl -w` (which runs as root) or `echo 1 | sudo tee <file>`.

> [!TIP]
> **Try it — read, change, and confirm the same knob two ways**
>
> ```sh
> sysctl net.ipv4.ip_forward
> sudo sysctl -w net.ipv4.ip_forward=1
> cat /proc/sys/net/ipv4/ip_forward
> sudo sysctl -w net.ipv4.ip_forward=0
> ```
>
> Expect something like:
>
> ```text
> net.ipv4.ip_forward = 0
> net.ipv4.ip_forward = 1
> 1
> net.ipv4.ip_forward = 0
> ```
>
> `sysctl -w` set the value and `cat` on the raw `/proc/sys` file shows the same `1` — they are the same parameter through two interfaces. The last line puts it back to `0`. On this single-interface VM, toggling `ip_forward` has no visible effect; on a real router it changes packet handling the instant it is set.

## Making a change persist

`sysctl -w` and direct writes are gone after a reboot. To make a parameter stick, put the dot-name in a `.conf` file. `/etc/sysctl.conf` is the traditional single file; the modern convention is a drop-in under `/etc/sysctl.d/` (for example `99-mytuning.conf`), which packages and admins can manage separately.

`sysctl -p` with no argument reads only `/etc/sysctl.conf`. To apply every drop-in directory as the system does at boot, use `sysctl --system` (or `sysctl -p /etc/sysctl.d/99-mytuning.conf` for just that file).

> [!TIP]
> **Try it — persist and re-apply**
>
> ```sh
> echo 'net.ipv4.ip_forward = 1' | sudo tee /etc/sysctl.d/99-playground.conf
> sudo sysctl --system | grep ip_forward
> sysctl net.ipv4.ip_forward
> sudo rm /etc/sysctl.d/99-playground.conf
> sudo sysctl -w net.ipv4.ip_forward=0
> ```
>
> Expect something like:
>
> ```text
> net.ipv4.ip_forward = 1
> * Applying /etc/sysctl.d/99-playground.conf ...
> net.ipv4.ip_forward = 1
> net.ipv4.ip_forward = 1
> ```
>
> `sysctl --system` walked the drop-in directories, applied `99-playground.conf`, and the parameter now reads `1` and would survive a reboot. The last two lines remove the file and reset the running value, leaving the VM as you found it.

> [!WARNING]
> **Common pitfalls**
>
> - **`sudo echo 1 > /proc/sys/...`.** The shell performs the `>` redirect as your user before `sudo` starts, so it fails with "Permission denied". Use `sudo sysctl -w name=value` or `echo 1 | sudo tee /proc/sys/...`.
> - **Expecting `sysctl -p` to read `/etc/sysctl.d/`.** Bare `sysctl -p` only reads `/etc/sysctl.conf`. Use `sysctl --system` for the drop-in directories, or pass the file path explicitly.
> - **Editing `/proc/sys` and calling it permanent.** Runtime writes vanish on reboot. Persistence needs a `.conf` file plus a reload.
> - **Trusting `/etc/mtab` as a separate record.** It is a symlink to `/proc/self/mounts` on current systems. `/proc/mounts` is the authority.
> - **Assuming every `/sys` file is read-only.** Many are, but some are controls. Writing the wrong one (I/O scheduler, device power state) can disrupt a running system — change `/sys` values only when you know what the attribute does.
