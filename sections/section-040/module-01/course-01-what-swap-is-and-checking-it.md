# What Swap Is and Checking What You Have

Swap is not "more RAM", and the kernel does not reach for it only in an emergency. It is a second, slower tier that the kernel manages all the time as part of ordinary housekeeping. Once you see when and why the kernel uses it, every later step in this module makes sense.

## What swap is

Think of the ship's flight deck (RAM) and a spare cargo hold (swap). The deck is fast to reach but small. When it fills up, the crew moves crates nobody is using into the hold. Getting a crate back is slower, but nothing is thrown away. The kernel moves memory in small 4 KiB pieces called pages, and it does this on its own, not in whole crates you choose.

With swap active, the kernel writes the least recently used pages out to the swap area when free RAM runs low. It hands that RAM to whatever needs it. If a process touches a swapped page again, the kernel reads it back. Things slow down, but services keep running instead of being killed.

Underneath, the kernel keeps every page on one of two lists: **active** (touched recently) and **inactive** (not touched for a while). A background kernel thread called `kswapd` wakes up when free memory drops below a low mark. It moves cold pages from the inactive list out to swap before the ship is truly starved. Only when requests arrive faster than `kswapd` can work does a process have to free memory itself. That slow path is called **direct reclaim**.

This is why an idle machine with gigabytes of free RAM can still show a little swap in use. `kswapd` moved some idle pages out earlier, and nothing needed them back.

Swap does not replace enough RAM. A ship that swaps heavily all the time is "thrashing": every page fault now costs a disk read instead of a memory read. Swap absorbs spikes and parks idle memory. It is also required for hibernation, because the whole memory image must be stored somewhere while the machine is off.

## Checking what you have

Two commands show the picture. `free -h` summarises RAM and swap in human-readable units. `swapon --show` lists each active swap area with its type, size, used amount and priority.

<!-- astrona:playground:renew -->

### See it in your playground

Run both commands to see the baseline:

```sh
free -h
swapon --show
```

Expect something like this (your numbers will differ a little):

```text
               total        used        free      shared  buff/cache   available
Mem:           1.9Gi       180Mi       1.5Gi       1.0Mi       280Mi       1.6Gi
Swap:             0B          0B          0B

(swapon --show prints nothing when no swap is active)
```

`Swap: 0B` and an empty `swapon --show` mean this ship has no swap yet. Only the OOM killer stands between it and a memory spike. The rest of the module changes that.

You can also read the live counters the model above is built on:

```sh
grep -E 'SwapTotal|SwapFree|Active\(anon\)|Inactive\(anon\)' /proc/meminfo
```

`/proc/meminfo` is the core's status screen. The kernel builds each line fresh every time you read it, and the values are in kibibytes.

## Common pitfalls

> [!WARNING]
> - **Reading "some swap used" as a warning.** On an idle system it is normal. `kswapd` already moved cold pages out, and nobody needed them back.
> - **Confusing `free` with `available`.** The `free` column leaves out memory the kernel can reclaim from the page cache. `available` is the better answer to "how much can a new program get".
> - **Expecting `swapon --show` to print an empty table header.** With no swap active it prints nothing at all.
> - **Treating swap as extra RAM.** Constant swapping makes the ship crawl. It is a buffer for spikes, not a fix for a chronic memory shortage.
