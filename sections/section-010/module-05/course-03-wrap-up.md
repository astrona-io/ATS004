# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about `/etc/fstab`, the ship's logbook of holds to dock at every launch, and how to write an entry that survives a reboot without breaking it.

**From [fstab Fields and Stable Identifiers](./course-01-fields-and-stable-identifiers.md):**

- An `/etc/fstab` line has six fields: device, mount point, type, options, dump and pass.
- The kernel does not read `/etc/fstab`. At boot, systemd's fstab generator turns each line into a `.mount` unit. `sudo mount -a` reads the file by hand and mounts every entry that is not already mounted.
- `findmnt --fstab` shows what the file says; `findmnt /` shows what is actually mounted now.
- Device names like `/dev/vdb` follow the order the kernel finds the disks, so they can change. Use `UUID=` (the default choice), `LABEL=` or `PARTUUID=`. `blkid` prints them all.
- The mount point directory must exist, or `mount -a` fails.

**From [Options and Verifying Before You Trust It](./course-02-options-and-verifying.md):**

- `defaults` expands to `rw,suid,dev,exec,auto,nouser,async`.
- `nofail` lets boot go on when a secondary disk is missing. Do not use it on a filesystem the system needs.
- `_netdev` makes systemd wait for the network before a network mount. `noatime` skips the access-time write on every read.
- `dump` is `0`. `pass` is `1` for root, `2` for other local filesystems, and `0` for network mounts, swap and XFS.
- A failed entry without `nofail` can drop the boot to an emergency shell.
- `findmnt --verify` checks the file without mounting; `sudo mount -a` really tries every mount. Run both before any reboot.

## Your missions

You proved the skill in a graded mission, right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Persistent fstab Mounting](./labs/lab-01/README.md) | Options and Verifying Before You Trust It | format a disk, add a `UUID=` entry with `nofail`, `dump` 0 and `pass` 2, mount it and verify the file |

If you skipped it, go back to it now. It is short, and the exam asks for exactly this skill.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. What are the six fields of an <code>/etc/fstab</code> line, in order?</summary>

Device, mount point, type, options, dump and pass.
</details>

<details>
<summary>2. Why should the device field use <code>UUID=</code> instead of <code>/dev/vdb</code>?</summary>

The kernel gives out device names in the order it finds the disks. Add a disk and `/dev/vdb` can become `/dev/vdc`, so the line could mount the wrong disk or nothing. A UUID is written into the filesystem by `mkfs` and never changes.
</details>

<details>
<summary>3. What <code>pass</code> value does a data filesystem get? The root filesystem? Swap?</summary>

`2` for a data filesystem, `1` for root, and `0` for swap (and for network mounts).
</details>

<details>
<summary>4. A secondary disk is missing at boot. What happens with <code>nofail</code>, and without it?</summary>

With `nofail`, systemd marks the mount as not critical, skips it, and boot goes on. Without it, the mount fails, the units that depend on it fail too, and the boot drops to an emergency shell.
</details>

<details>
<summary>5. What does <code>findmnt --verify</code> check that <code>sudo mount -a</code> does not, and the other way round?</summary>

`findmnt --verify` reads the file and flags problems without mounting anything, such as unknown types or missing mount points. `sudo mount -a` really tries every mount, the same attempt a `.mount` unit makes at boot. Run both before a reboot.
</details>

<details>
<summary>6. Which option does an NFS mount need so it is not tried before the network is up?</summary>

`_netdev`. It tells systemd's fstab generator to start the mount after the network is online.
</details>

## Clean up the playground

When you are done, land everything cleanly. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its **name**, not its folder path:

```sh
astrona destroy section-010-module-05-playground
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-004-lab-015
```

Then check that everything is gone:

```sh
astrona list
```

The list should no longer show the playground or the mission. You can start the playground again at any time with the `astrona run` command for this module. It always starts clean, with a fresh backup of `/etc/fstab`, so nothing you broke carries over.

> *Write the logbook with a serial number, not a door number, and test every line before you land: `findmnt --verify` first, then `sudo mount -a`.*
