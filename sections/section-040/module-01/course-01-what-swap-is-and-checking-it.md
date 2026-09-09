# Part 1 — What Swap Is & Checking What You Have

> Prerequisite: [Module landing page](./course.md). Next: [Part 2 — Allocating, Activating & Deactivating a Swap File](./course-02-allocating-activating-deactivating.md).

Before touching a single command, get the mental model right: swap is not "more RAM" and it is not optional overflow storage the kernel reaches for only in an emergency. It is a second, slower tier the kernel actively manages as part of ordinary memory housekeeping — understanding *when* and *why* it gets used explains everything the rest of this module does to it.

## What swap is

> As an analogy: RAM is your desk — fast to reach, small. Swap is the drawer under it. When the desk is full you move the folders you are not using into the drawer; retrieving them later is slower, but nothing is thrown away. The analogy breaks down because the kernel moves memory in and out of swap continuously and automatically, in 4 KiB pages, not in whole "folders" you choose.

Concretely: with swap active, when free RAM gets low the kernel writes the least-recently-used pages out to the swap area and hands that RAM to whatever needs it. If those pages are touched again, they are read back in. Throughput drops while this happens, but services keep running instead of being killed.

Underneath, the kernel keeps every page of memory on one of two lists: **active** (recently touched) and **inactive** (not touched in a while). A background kernel thread, `kswapd`, wakes up when free memory crosses a low watermark and starts moving cold pages from the inactive list out to swap *before* the system is actually starved — a pre-emptive reclaim, not a last-second scramble. Only if allocation requests outrun `kswapd`'s pace does a process stall doing **direct reclaim** itself. This is why a lightly-loaded system can show a few hundred KB of swap used even with gigabytes of RAM free: `kswapd` already moved some genuinely idle pages out, and there was no reason to move them back.

One tunable governs how eager that pre-emptive move is: `vm.swappiness` (0–200 on modern kernels, default 60) sets how aggressively the kernel prefers reclaiming page cache versus swapping out anonymous (process) memory. A higher value swaps sooner; `0` avoids swapping until reclaiming cache alone cannot free enough memory. This module does not change it, but it explains why two systems with identical RAM and swap can behave differently under the same load.

Swap is not a substitute for enough RAM — a system that swaps heavily and constantly ("thrashing") is slow, because every page fault now costs a disk read instead of a memory access. It is a buffer for spikes and idle memory, and it is required for hibernation (the entire RAM image has to fit somewhere while the machine is powered off).

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
> `Swap: 0B` and an empty `swapon --show` mean this VM has no swap yet — the OOM killer is the only thing standing between it and a memory spike. The rest of this module changes that.

> *Swap is not an emergency fallback — `kswapd` is already moving cold pages out before you run low, which is why "some swap used" on an idle system is normal, not a warning sign.*

## Reference

- `man free` — the exact meaning of each column, including `available` versus `free`.
- `man 5 proc`, `/proc/meminfo` — `SwapCached`, `Active(anon)`, `Inactive(anon)` are the live counters behind this section's model.
