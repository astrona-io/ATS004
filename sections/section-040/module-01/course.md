# Temporary Safety Valves: Swap Files

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-040/module-01/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-040/module-01/playground
> astrona destroy section-040-module-01-playground
> ```

When a Linux machine runs out of physical RAM and has no swap, the kernel's Out-Of-Memory (OOM) killer picks a process and terminates it to free memory. It aims at large, low-priority processes, but the one it lands on is often something you care about. Swap space gives the kernel somewhere to park idle memory pages instead, so a memory spike slows the system down rather than killing a service.

This module covers the quickest way to add swap to a running system: a swap file. You will allocate it, lock down its permissions, format it for swap, activate it, and turn it off again.

## Learning objectives

After this module you can:

- Explain what swap space does and how it changes the kernel's behaviour under memory pressure.
- Allocate a swap file with `fallocate` and explain why `chmod 600` on it matters.
- Format a file for swap with `mkswap` and activate it with `swapon`.
- Read active swap areas from `swapon --show` and `free`.
- Deactivate a swap file with `swapoff` and describe when that command fails.

## Before you start

You should know basic file commands (`ls`, `chmod`, `rm`), `sudo`, and how to read sizes in command output.

The linked playground gives you an Ubuntu server VM with 2 GB RAM, an ext4 root filesystem with room to spare, passwordless `sudo`, and the swap tools installed. `bootstrap/prepare.sh` prints the starting memory and swap picture. Run the command blocks below in that VM after connecting with `astrona ssh section-040-module-01-playground`.

## What swap is

> As an analogy: RAM is your desk — fast to reach, small. Swap is the drawer under it. When the desk is full you move the folders you are not using into the drawer; retrieving them later is slower, but nothing is thrown away. The analogy breaks down because the kernel moves memory in and out of swap continuously and automatically, in 4 KiB pages, not in whole "folders" you choose.

Concretely: with swap active, when free RAM gets low the kernel writes the least-recently-used pages out to the swap area and hands that RAM to whatever needs it. If those pages are touched again, they are read back in. Throughput drops while this happens, but services keep running instead of being killed.

Swap is not a substitute for enough RAM — a system that swaps heavily and constantly ("thrashing") is slow. It is a buffer for spikes and idle memory, and it is required for hibernation.

## Checking what you have

Two commands show the current picture: `free` (with `-h` for human-readable units) summarises RAM and swap totals; `swapon --show` lists each active swap area, its type, size, used amount, and priority.

> [!TIP]
> **Try it — the baseline**
>
> ```sh
> free -h
> swapon --show
> ```
>
> Expect something like:
>
> ```text
>                total        used        free      shared  buff/cache   available
> Mem:           1.9Gi       180Mi       1.5Gi       1.0Mi       280Mi       1.6Gi
> Swap:             0B          0B          0B
>
> (swapon --show prints nothing when no swap is active)
> ```
>
> `Swap: 0B` and an empty `swapon --show` mean this VM has no swap yet — the OOM killer is the only thing standing between it and a memory spike. The rest of the chapter changes that.

## Allocating and securing the file

A swap file is an ordinary file whose blocks the kernel uses as swap. `fallocate -l <size> <path>` reserves the space by asking the filesystem to mark the blocks as allocated, without writing them — near-instant on ext4 and XFS. (On Btrfs a `fallocate`d file is unsuitable for swap; there you need a specific procedure with `chattr +C`. The playground's root filesystem is ext4, so `fallocate` is fine.)

The permissions matter. When the kernel swaps a page out, it writes the raw contents of memory — which can include passwords and keys — into the file. If any user can read the swap file, they can read those secrets off disk. Set the file to mode `600` (owner read/write only, and the owner is root) before activating it. `swapon` will warn about "insecure permissions" on a world-readable file and still activate it, so the check is on you.

> [!TIP]
> **Try it — allocate, then lock it down**
>
> ```sh
> sudo fallocate -l 512M /swapfile
> ls -lh /swapfile
> sudo chmod 600 /swapfile
> ls -l /swapfile
> ```
>
> Expect something like:
>
> ```text
> -rw-r--r-- 1 root root 512M Aug 29 12:00 /swapfile
> -rw------- 1 root root 512M Aug 29 12:00 /swapfile
> ```
>
> The file is 512 MiB immediately (no long `dd` wait). After `chmod 600` the permission string is `-rw-------`: only root can read it, so pages written there are not exposed.

## Formatting and activating

`mkswap <path>` writes a swap header (a signature, a UUID, and a page map) into the file, turning it into something the memory manager recognises. `swapon <path>` then tells the kernel to start using it. Both need root.

> [!TIP]
> **Try it — format, activate, and confirm**
>
> ```sh
> sudo mkswap /swapfile
> sudo swapon /swapfile
> swapon --show
> free -h
> ```
>
> Expect something like:
>
> ```text
> Setting up swapspace version 1, size = 512 MiB (536866816 bytes)
> no label, UUID=1b9e...c4
>
> NAME      TYPE SIZE USED PRIO
> /swapfile file 512M   0B   -2
>
>                total        used        free      shared  buff/cache   available
> Swap:          512Mi          0B       512Mi
> ```
>
> `swapon --show` now lists `/swapfile`, and `free` shows a 512 MiB swap total. `PRIO -2` is the automatic priority; the next module covers setting it deliberately. If RAM now fills, idle pages go here instead of triggering the OOM killer.

## Deactivating

`swapoff <path>` stops the kernel using that area. It first copies every page currently in the swap file back into RAM, so it needs enough free RAM (plus other swap) to hold that data — on a memory-starved system `swapoff` can be slow or fail with "Cannot allocate memory". Once it succeeds, the file is just a file again and you can delete it.

> [!TIP]
> **Try it — turn it off and clean up**
>
> ```sh
> sudo swapoff /swapfile
> swapon --show
> sudo rm /swapfile
> free -h
> ```
>
> Expect something like:
>
> ```text
> (swapon --show prints nothing again)
>
> Swap:             0B          0B          0B
> ```
>
> `swapoff` removed `/swapfile` from the active list and `free` shows swap back at zero. Because almost nothing was in swap, the copy-back was instant; on a busy system this step can take a while.

> [!WARNING]
> **Common pitfalls**
>
> - **World-readable swap.** A swap file that skips `chmod 600` exposes swapped-out memory — including secrets — to any local user. `swapon` only warns, it does not stop you.
> - **`fallocate` on the wrong filesystem.** On Btrfs a `fallocate`d file will not work as swap (`swapon` fails). Use ext4/XFS, or Btrfs's dedicated procedure.
> - **Expecting the swap file to survive a reboot.** `swapon /swapfile` is not persistent. It must be added to `/etc/fstab` (next module) to come back automatically.
> - **`swapoff` on a system under memory pressure.** It has to pull all swapped pages back into RAM. If they do not fit, it fails and the swap stays active. Free memory first, or add other swap.
> - **Treating swap as extra RAM.** Heavy, constant swapping ("thrashing") makes a system crawl. Swap absorbs spikes; it does not fix a chronic RAM shortage.
