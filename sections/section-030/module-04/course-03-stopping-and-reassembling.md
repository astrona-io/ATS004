# Stopping, Reassembling and Reusing Disks

Arrays do not live in the kernel only. The truth lives in the superblocks on the disks, and that is why you can stop an array, move its disks, and bring it back. This page shows how to stop an array, assemble it again, and clear a disk that you want to use for something else.

## Stop and assemble

`mdadm --stop /dev/md0` shuts the array down. It works only if nothing uses the array: unmount the filesystem first. The member disks are untouched. Their superblocks keep the array's UUID, the level and each disk's role.

`mdadm --assemble --scan` brings back every array it can find. It reads `/etc/mdadm/mdadm.conf` and the superblocks. You can also name the members yourself: `mdadm --assemble /dev/md0 /dev/vdb /dev/vdc /dev/vdd`.

> As an analogy: stopping an array is docking the three holds. Each hold carries its own ID plate (the superblock). When the crew meets again, it reads the plates and joins the holds back in the right roles. The analogy breaks down because a hold with an old, out-of-date plate is treated as stale and is left out.

### See it in your playground

Unmount the filesystem, stop the array, and bring it back. The disk names are in `/etc/playground-raid`.

<!-- astrona:playground:renew -->

```sh
. /etc/playground-raid
sudo umount /mnt/raid
sudo mdadm --stop /dev/md0
cat /proc/mdstat
```

`/proc/mdstat` should no longer list `md0`. Read one member's plate to see that the data is still there:

```sh
sudo mdadm --examine "$member1"
```

The output still names the array UUID, the level `raid5`, and the member's role. Now assemble and mount again:

```sh
sudo mdadm --assemble --scan
cat /proc/mdstat
sudo mount /dev/md0 /mnt/raid
cat /mnt/raid/data.txt
```

The array returns with all three members up, and the sample file reads as before. If `--assemble --scan` finds nothing, the `ARRAY` line is missing from `mdadm.conf`; name the members by hand as shown above.

## A disk that has been in an array

A raw spare has no plate. Check with `sudo mdadm --examine "$spare"`: it reports that no md superblock was found.

A disk that was once a member still has its plate. If you want to reuse it, clear the plate first:

```text
sudo mdadm --zero-superblock /dev/vdX
```

Run this only on a disk that is **not** part of a running array and that you no longer need. On a live member it destroys that member's role record.

## Common pitfalls

> [!WARNING]
> - **Stopping an array that is still mounted.** `mdadm --stop` fails with "device busy". Run `umount` first.
> - **Running `--zero-superblock` on a current member.** The array loses that disk and runs degraded, or does not assemble. Check `mdadm --detail /dev/md0` first.
> - **Forgetting that the ID plate can be stale.** A disk with a low `Events` count is left out on assemble. Re-add it so that it syncs.
> - **Moving disks to another machine and expecting `md0`.** The name can change (for example `/dev/md127`). Mount by the filesystem UUID.

## Your mission: RAID Stop, Reassemble and Wipe Lab

You can now stop an array, assemble it again from named disks, and clear an old RAID label. The mission asks you to stop a mounted RAID 1 mirror, assemble it again with `mdadm --assemble`, and erase a leftover label from a spare disk with `--zero-superblock`.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory. It always starts clean again:

```sh
astrona destroy section-030-module-04-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-030/module-04/labs/lab-03
astrona ssh ats-004-lab-030-04-03
```

Read the task in [`question.md`](./labs/lab-03/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-030/module-04/labs/lab-03
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-030-04-03
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-030/module-04/playground
```
