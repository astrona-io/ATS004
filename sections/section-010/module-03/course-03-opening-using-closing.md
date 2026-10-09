# Opening, Using and Closing the Vault

A LUKS container with a header and keyslots is a locked vault door with nothing behind it yet. This part covers the everyday work: open the disk, build a filesystem on it, store a file, and lock it again. Then you look at the raw bytes, the way a thief with your disk would see them.

## Opening, using and closing the vault

You follow the same short cycle every time you use an encrypted disk. Each step below runs on the playground disk `/dev/vdb`, which already holds a LUKS container with your passphrase.

`cryptsetup open <device> <name>` asks for a passphrase. It tries the passphrase against each keyslot in turn. On the first match, the kernel's device mapper creates the airlock: a new device that the system names `/dev/mapper/<name>`. From then on you treat that path as the disk. You run `mkfs.ext4 /dev/mapper/<name>`, mount it, use it, unmount it, and finally run `cryptsetup close <name>`.

Always format the mapped device, never the raw disk. Running `mkfs.ext4 /dev/vdb` now would write a filesystem straight over the LUKS header and keyslots. That does not "encrypt them again". It destroys the only records that know how to get the master key back, and no passphrase can fix a header that has been written over.

### Open the vault

Open the disk under the name `secure_vault`, type your passphrase, and look at the new device:

<!-- astrona:playground:renew -->

```sh
sudo cryptsetup open /dev/vdb secure_vault
ls -l /dev/mapper/secure_vault
```

Expect something like:

```text
lrwxrwxrwx 1 root root 7 Aug 29 12:00 /dev/mapper/secure_vault -> ../dm-0
```

The kernel created a new block device, `dm-0`, and `/dev/mapper/secure_vault` is a friendly name that points to it. This is the airlock you work through from now on.

### Build the shelves and dock the hold

Put an ext4 filesystem on the mapped device, mount it, write a file, and check the space:

```sh
sudo mkfs.ext4 /dev/mapper/secure_vault
sudo mkdir -p /mnt/vault
sudo mount /dev/mapper/secure_vault /mnt/vault
echo "top secret" | sudo tee /mnt/vault/notes.txt
df -h /mnt/vault
```

The `df` line looks something like this (the rest of the output is left out):

```text
Filesystem                Size  Used Avail Use% Mounted on
/dev/mapper/secure_vault  1.9G   24K  1.8G   1% /mnt/vault
```

While it is open, `secure_vault` works just like a plain disk. `df` shows the ext4 filesystem mounted through it. The size is a little under 2 GB, because the LUKS header takes the first 16 MiB.

### Undock and lock it again

Unmount the filesystem, close the vault, and list what is left under `/dev/mapper/`:

```sh
sudo umount /mnt/vault
sudo cryptsetup close secure_vault
ls /dev/mapper/
```

After `close`, only `control` remains under `/dev/mapper/`. The airlock is gone, and the data on `/dev/vdb` is just scrambled bytes again.

If you skip the `umount`, `close` fails with "Device secure_vault is busy". The kernel cannot remove the device-mapper target while a mounted filesystem still uses it, just as a hold cannot undock while crew are still inside. On Ubuntu 24.04 the exact wording of this message may differ, for example "is still in use".

## What the locked disk looks like from outside

With the disk closed, someone who copies `/dev/vdb` gets two things. First comes the LUKS header, a small structure that says clearly what it is. After it comes the scrambled data area, which looks just like random noise. They see no file names, no sizes and no contents.

This is not hiding by trickery. Nothing unscrambled was ever written to this disk. The only readable part is the header, and it is meant to be readable, so that any LUKS tool can find the cipher and the keyslots to try. Everything else is AES-XTS output.

### See it in your playground: read the raw bytes

`xxd` shows bytes as hexadecimal numbers. The `-l` option limits how many bytes it shows, and `-s` jumps to a byte position first. Read the start of the disk, then a spot deep in the data area:

```sh
sudo xxd -l 96 /dev/vdb
sudo xxd -s 20000000 -l 64 /dev/vdb
```

Expect something like this (shortened; the `<--` notes are added for you and are not part of the output):

```text
00000000: 4c55 4b53 babe 0002 ...   LUKS............     <-- 'LUKS' magic + version
...
01312d00: 9c3e a71f 4b02 ...        .>..K...........     <-- deep in the data area: noise
```

The first four bytes spell `LUKS`, and the header gives the version and the cipher. That part is readable on purpose, so tools know how to unlock the disk. Everything in the data area looks random: nothing about your files shows without the passphrase.

## Common pitfalls

> [!WARNING]
> - **Formatting the raw disk after LUKS.** `mkfs.ext4 /dev/vdb` (instead of `/dev/mapper/...`) writes over the LUKS header and keyslots. The passphrase becomes useless. Once the disk is open, always work on the `/dev/mapper/` name.
> - **Running `close` while the disk is still mounted or in use.** `cryptsetup close` fails with "device is busy" if the filesystem is mounted or a process holds a file open. Run `umount` first. If that fails too, find the process that holds the mount with `lsof` or `fuser -mv` and stop it before you close.

> *`open` gets the master key back and builds the airlock, `close` takes the airlock down, and what is left on the disk is always the header plus noise. Your data never touches the disk unscrambled.*

## Your mission: LUKS Block-level Encryption

You can now lock a disk with LUKS, open it to a `/dev/mapper/` name, and put a mounted ext4 filesystem on it. The mission asks you to do this on a fresh 2 GB disk: open it as `secure_volume`, mount it at `/mnt/secure-data`, and leave a marker file on it.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory; it always starts clean again:

```sh
astrona destroy section-010-module-03-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-010/module-03/labs/lab-01
astrona ssh ats-004-lab-012
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-03/labs/lab-01
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-012
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-010/module-03/playground
```
