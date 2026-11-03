# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about XFS: building it, docking it for good, growing it and checking it.

**From [Creating and Inspecting XFS](./course-01-creating-and-inspecting-xfs.md):**

- `mkfs.xfs -L <label> <device>` builds the filesystem. It refuses to overwrite an existing one unless you add `-f`.
- `xfs_info <mount point>` shows the allocation groups, the block size and the log.
- Allocation groups are decks with their own free-space lists, so many writers work in parallel. The log is the notebook that is replayed after a crash.
- XFS can grow but never shrink.
- `noatime` stops reads from writing access times. A `UUID=` line in `/etc/fstab` makes the mount persistent, and `findmnt --verify` and `mount -a` test it.

**From [Growing and Repairing XFS](./course-02-growing-and-repairing-xfs.md):**

- The device grows first. Then `xfs_growfs <mount point>` makes the mounted filesystem use the new space.
- `fsck.xfs` does nothing. A real check is `xfs_repair`, on an undocked filesystem only.
- `xfs_repair -n` is a dry run. Exit status `0` means clean, `1` means damage was found.
- `xfs_repair -L` zeroes the log and loses unwritten changes. It is the last resort.
- `xfs_admin -L` and `xfs_admin -U` change the label and the UUID.

## Your missions

You proved the skill in a graded mission, right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [XFS Create, Mount and Check](./labs/lab-01/README.md) | Growing and Repairing XFS | format a blank disk as XFS with a label, mount it by UUID from `/etc/fstab`, and dry-run `xfs_repair -n` on an undocked disk |

If you skipped it, go back to it now. It is short, and the exam asks for exactly this skill.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. You must make an XFS filesystem smaller. What do you do?</summary>

XFS cannot shrink. Copy the data out, build a smaller filesystem and copy the data back.
</details>

<details>
<summary>2. You extended a logical volume. Which command makes the mounted XFS filesystem use the space, and what do you give it?</summary>

`sudo xfs_growfs <mount point>`. It takes the mount point, not the device.
</details>

<details>
<summary>3. You run <code>xfs_repair /dev/vdc</code> while the filesystem is mounted. What happens?</summary>

The tool refuses to run. Unmount the filesystem first. Use `xfs_repair -n` for a look that changes nothing.
</details>

<details>
<summary>4. Why does the boot process not repair XFS the way it can repair ext4?</summary>

`fsck.xfs` exists but does nothing. XFS replays its log at mount time, and a real repair is started by hand with `xfs_repair`.
</details>

<details>
<summary>5. When is <code>xfs_repair -L</code> acceptable?</summary>

Only when the log cannot be replayed even after you tried to mount the filesystem once. It zeroes the log and loses changes that were not yet written to the main tables.
</details>

<details>
<summary>6. Why does the <code>/etc/fstab</code> line for XFS end with <code>0 0</code> and use <code>UUID=</code>?</summary>

`0 0` turns off the dump flag and the boot-time check, which XFS does not use. `UUID=` keeps the line correct when device names such as `/dev/vdb` move.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-010-module-09-playground
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-004-lab-092
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the mission from this module. You can start the playground again at any time with the `astrona run` command from the end of the mission; it always starts clean, so nothing you broke carries over.

<!-- astrona:playground:destroy -->
