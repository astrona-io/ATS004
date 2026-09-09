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

## How this module is organised

1. **[Part 1 — What Swap Is & Checking What You Have](./course-01-what-swap-is-and-checking-it.md)** — the kernel's page-reclaim mechanism (`kswapd`, active/inactive lists, `vm.swappiness`) that explains *when* swap gets used, and reading the current picture with `free` / `swapon --show`.
2. **[Part 2 — Allocating, Activating & Deactivating a Swap File](./course-02-allocating-activating-deactivating.md)** — the full lifecycle: `fallocate`, `chmod 600`, what `mkswap`'s header actually contains, `swapon`, and `swapoff`.

## Learning objectives

After this module you can:

- Explain what swap space does, and describe the kernel's page-reclaim mechanism (`kswapd`, active/inactive lists) that decides when it gets used.
- Allocate a swap file with `fallocate` and explain why `chmod 600` on it matters.
- Format a file for swap with `mkswap` and state what its header actually contains.
- Activate it with `swapon` and read active swap areas from `swapon --show` and `free`.
- Deactivate a swap file with `swapoff` and describe when that command fails.

## Before you start

You should know basic file commands (`ls`, `chmod`, `rm`), `sudo`, and how to read sizes in command output.

The linked playground gives you an Ubuntu server VM with 2 GB RAM, an ext4 root filesystem with room to spare, passwordless `sudo`, and the swap tools installed. `bootstrap/prepare.sh` prints the starting memory and swap picture. Run the command blocks in both parts in that VM after connecting with `astrona ssh section-040-module-01-playground`.
