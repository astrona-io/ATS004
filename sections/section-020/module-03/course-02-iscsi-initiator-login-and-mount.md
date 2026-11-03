# The iSCSI Initiator: Discover, Log In and Mount

iSCSI is the network disk that data centres use. It carries disk commands over an ordinary network connection on port 3260. This part follows the full path on the client: discover a target, log in, find the disk that appears, then format and mount it.

## Names you need

Two words describe the two sides. The **target** is the server side: it offers disks. The **initiator** is your side: it asks for them. Think of the target as a ship with a cargo hold on offer, and the initiator as your ship calling it on the radio.

Each target has a long name called an IQN, an iSCSI Qualified Name. Ours is `iqn.2026-01.io.astrona:storage.cargo`. It reads as a fixed word `iqn`, the year and month the owner registered a domain, that domain written backwards, and a free name after the colon. The name is a label, not an address. The address is the IP and port.

On your ship, two things run the initiator. The `iscsid` service keeps the connections. The command `iscsiadm` talks to it.

## Discover and log in

The server for this part offers one target. First ask it what it has.

### See it in your playground

<!-- astrona:playground:renew -->

```sh
sudo iscsiadm -m discovery -t sendtargets -p 10.10.60.10
```

`iscsiadm` sends a "send targets" request to port 3260. The server answers with the target names it offers, one per line, with its address and port in front. The answer is also saved as a record on your ship, so you can log in without typing everything again.

Now log in to the target:

```sh
sudo iscsiadm -m node -T iqn.2026-01.io.astrona:storage.cargo -p 10.10.60.10 --login
sudo iscsiadm -m session
```

`--login` opens the session. `-m session` lists the open sessions, so the target name should appear there.

## Find the new disk

After the login, the kernel on your ship adds a new disk, as if someone had plugged a drive in.

```sh
lsblk
ls -l /dev/disk/by-path/
```

`lsblk` shows a new 1 GB disk, usually named `sda`. The `by-path` directory holds a name that contains the server address and the target name, and it points at that disk. Use the `by-path` name when you format, because device names such as `sda` can change after a restart while the `by-path` name stays the same. A `tgt` server also shows a small control entry as lun 0, so the data disk is usually the entry that ends in `lun-1`.

> [!TIP]
> To see which disk belongs to a session, run `sudo iscsiadm -m session -P 3`. The last lines of the output list the attached disk name.

## Format and mount

From here the disk behaves like any local disk. The filesystem belongs to your ship.

```sh
sudo mkfs.ext4 /dev/disk/by-path/<ISCSI-DISK-PATH>
sudo mount /dev/disk/by-path/<ISCSI-DISK-PATH> /mnt/cargo
findmnt /mnt/cargo
```

Replace `<ISCSI-DISK-PATH>` with the name you saw in `by-path`. `findmnt` shows `/mnt/cargo` with the type `ext4`.

## Log out

To detach the disk, undock it first, then close the session:

```sh
sudo umount /mnt/cargo
sudo iscsiadm -m node -T iqn.2026-01.io.astrona:storage.cargo -p 10.10.60.10 --logout
```

The disk disappears from `lsblk`. The data stays on the server, and logging in again brings the same filesystem back.

## Common pitfalls

> [!WARNING]
> - Formatting a disk without checking its size and path. Always compare `lsblk` with the by-path name before `mkfs`.
> - Using `/dev/sda` in configuration files. The name can change after a restart, so use the by-path name for commands and `UUID=` for `/etc/fstab`.
> - Logging out while the disk is still mounted.
> - Mistyping the target name. Copy it from the discovery output.
