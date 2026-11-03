# Reading an Array Closely

An array that runs is not the same as an array that is healthy. Three views show the real state: the kernel's short list, the full detail of the array, and the superblock on each member disk. This page teaches you to read all three, and to check the capacity maths for RAID 5.

## Three views of one array

- **`/proc/mdstat`** is the kernel's own status board. Each array has a line with its name, its state (`active`), its level, and its members. After each member name comes a number in square brackets: its role slot. Below it, a pair like `[3/3] [UUU]` shows how many members are expected, how many are present, and which are up. A `_` in place of a `U` means a missing member.
- **`mdadm --detail /dev/md0`** reads the same facts for one array and adds more: `Array Size`, `Chunk Size`, `State` (`clean`, `degraded`, `resyncing`), and a table of every member with its role (`active sync`, `spare`, `faulty`).
- **`mdadm --examine /dev/vdb`** reads the **superblock on one member disk**. It shows the array UUID, the level, the member's own role, and the `Events` counter. If one member has a lower `Events` value than the others, it missed writes and is stale.

> As an analogy: `/proc/mdstat` is the status light on the bridge, `--detail` is the ship's log, and `--examine` is the ID card each crew member carries. When the light turns amber, the log tells you what is wrong, and the ID cards tell you who was missing.

The command `mdadm --detail --scan` prints one `ARRAY` line per array. That is the line you copy into `/etc/mdadm/mdadm.conf`.

## The capacity check for RAID 5

RAID 5 with N disks of the same size gives N minus 1 disks of usable space, because one disk's worth of space holds parity. Three 1 GB disks give about 2 GB, not 3. The array size shown by `--detail` is a little under that, because the superblock and a data offset take some room on every member.

`--chunk=64` sets the chunk size, the amount of data written to one disk before the stripe moves to the next. The default is larger. A small chunk spreads small files over more disks. A large chunk suits big sequential files.

### See it in your playground

The four spare disks start raw. Build a three-disk RAID 5 array with a 64 KiB chunk. `--run` skips the confirmation prompt:

<!-- astrona:playground:renew -->

```sh
sudo mdadm --create /dev/md1 --level=5 --raid-devices=3 --chunk=64 --run /dev/vdb /dev/vdc /dev/vdd
cat /proc/mdstat
```

Look for the three member names, `[3/3] [UUU]`, and a `resync` or `recovery` progress bar while the initial parity is built. Now read the same array in full, then read one member:

```sh
sudo mdadm --detail /dev/md1
sudo mdadm --examine /dev/vdb
sudo mdadm --detail --scan
```

In the `--detail` output, find `Raid Level : raid5`, `Chunk Size : 64K`, and an `Array Size` near 2 GiB. In the `--examine` output, find the same Array UUID and the `Events` counter. In the table at the end of `--detail`, every member should show `active sync` once the build is done.

## Common pitfalls

> [!WARNING]
> - **Reading only `/proc/mdstat`.** It shows that members are up, not why a disk dropped. Use `--detail` and `--examine`.
> - **Reading `mdadm --examine` on the array device.** It reads a member's superblock, so run it on `/dev/vdb`, not on `/dev/md1`.
> - **Expecting N disks of space from RAID 5.** You get N minus 1.
> - **Using the array before the first sync ends.** It works, but a disk failure then costs data. Watch `/proc/mdstat` until the bar is gone.
