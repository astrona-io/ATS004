# Wrap-Up: Mission Debrief

Well flown, astronaut. You attached disks from another ship over the network. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

**From [Block Devices Versus Shared Files, and NBD](./course-01-block-versus-file-sharing-and-nbd.md):**

- A shared filesystem such as NFS gives you files, and the server owns the shelves. A network block device gives you a raw disk, and your ship builds the filesystem.
- A network block device belongs to one client at a time.
- `nbd-client -l server` lists the exports, `nbd-client server /dev/nbd0 -N cargo` connects one, and `nbd-client -d /dev/nbd0` disconnects it. The `nbd` kernel module must be loaded.

**From [The iSCSI Initiator: Discover, Log In and Mount](./course-02-iscsi-initiator-login-and-mount.md):**

- The server side is the target, your side is the initiator. A target has a name called an IQN, and it listens on port 3260.
- `iscsiadm -m discovery -t sendtargets -p <address>` finds targets, `iscsiadm -m node -T <name> -p <address> --login` logs in, `iscsiadm -m session` lists sessions, and `--logout` ends one.
- The new disk shows in `lsblk` and under `/dev/disk/by-path/`. The by-path name does not change after a restart.

**From [Making the Disk Come Back After a Restart](./course-03-persistence-and-pitfalls.md):**

- A network disk goes in `/etc/fstab` by `UUID=` with the option `_netdev`, so systemd waits for the network.
- `node.startup = automatic` makes the `iscsid` service log in at launch. Check it with `iscsiadm -m node -T <name> -p <address>`.
- `sudo findmnt --verify` and `sudo mount -a` prove the line before a restart.

## Your missions

| Mission | After the part | What you proved |
| --- | --- | --- |
| [iSCSI Disk on a Remote Server](./labs/lab-01/README.md) | Making the Disk Come Back After a Restart | log in to an iSCSI target, format its disk as ext4, mount it at `/mnt/cargo` with a `UUID=` and `_netdev` fstab line, and set automatic login |

If you skipped it, go back to it now. The exam asks for exactly this skill.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. What is the difference between mounting an NFS share and attaching an NBD export?</summary>

NFS gives you files from a filesystem that the server owns. An NBD export gives you a raw disk, and your ship runs `mkfs` on it and owns the filesystem.
</details>

<details>
<summary>2. What does <code>nbd-client -d /dev/nbd0</code> do, and what must you do first?</summary>

It disconnects the device from the server. Unmount the filesystem first with `umount`.
</details>

<details>
<summary>3. Which command finds the iSCSI targets on <code>10.10.60.10</code>?</summary>

`sudo iscsiadm -m discovery -t sendtargets -p 10.10.60.10`
</details>

<details>
<summary>4. After the login, how do you find the new disk, and which name is stable?</summary>

Use `lsblk` and `ls -l /dev/disk/by-path/`. The by-path name stays the same after a restart, while `/dev/sda` can change.
</details>

<details>
<summary>5. Why does an fstab line for an iSCSI disk need <code>_netdev</code>?</summary>

The disk exists only after the network is up. `_netdev` makes systemd wait for the network before it mounts the disk.
</details>

<details>
<summary>6. The fstab line is correct, but the disk is not mounted after a restart. What else do you check?</summary>

Whether the login happens at launch: `node.startup` must be `automatic`, and the `iscsid` service must be active.
</details>

## Clean up the playground

Land your training ships before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-020-module-03-playground
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-004-lab-100
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the mission from this module. You can start the playground again at any time; it always starts clean.
