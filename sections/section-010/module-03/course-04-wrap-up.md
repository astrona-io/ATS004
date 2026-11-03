# Wrap-Up: Mission Debrief

Well flown, astronaut. You have fitted a vault door on a cargo hold, opened it, used it and locked it again. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about LUKS, the vault door that keeps a disk's cargo safe when someone else holds the disk.

**From [The LUKS Model: Locking a Disk](./course-01-the-luks-model.md):**

- LUKS protects data at rest: a disk that is stolen, copied or thrown away. It does not protect a running system where the disk is already open and mounted.
- A LUKS disk is either locked (scrambled bytes, no filesystem visible) or mapped (an unscrambled device under `/dev/mapper/`).
- Four commands move the disk between the states: `luksFormat` once, then `open`, use it (`mkfs`, `mount`, `umount`), and `close`.
- The mapped device is a device-mapper target. The kernel's `dm-crypt` scrambles and unscrambles each block on the way through. Nothing unscrambled is ever written to the disk.
- The default cipher is `aes-xts-plain64`. XTS scrambles each sector on its own, using its position, so one sector can be rewritten without touching any other.

**From [Creating a Container and Its Keyslots](./course-02-creating-a-container-and-keyslots.md):**

- `cryptsetup luksFormat <device>` writes a LUKS2 header. It asks for `YES` in capital letters, then a passphrase twice.
- `cryptsetup luksDump` shows the header: the cipher, where the data area starts (16 MiB in) and the keyslots in use.
- A random master key scrambles the data. Your passphrase, run through Argon2id, only locks a copy of the master key in a keyslot.
- `luksAddKey` adds a passphrase in a new keyslot, and `luksKillSlot` removes one. Neither touches the data area.
- With no known passphrase and no header backup (`luksHeaderBackup`), the data is gone for good.

**From [Opening, Using and Closing the Vault](./course-03-opening-using-closing.md):**

- `cryptsetup open <device> <name>` creates `/dev/mapper/<name>`, a friendly name for a new `dm-` device.
- Always run `mkfs` on the `/dev/mapper/` device. Running it on the raw disk destroys the header and keyslots.
- `umount` first, then `cryptsetup close`. Closing a mounted device fails because it is busy.
- A closed disk shows the readable `LUKS` header, then data that looks like random noise.

## Your missions

You proved the skill in a graded mission, right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [LUKS Block-level Encryption](./labs/lab-01/README.md) | Opening, Using and Closing the Vault | lock a raw disk with LUKS, open it as `secure_volume`, format it with ext4 and mount it at `/mnt/secure-data` |

If you skipped it, go back to it now. It is short, and the exam asks for exactly this skill.

## Check yourself

Try to answer each question before you open it.

<details>
<summary>1. A server is running, and its LUKS disk is open and mounted. Does LUKS stop a user with normal file access from reading the files?</summary>

No. Once the disk is open and mounted, the kernel unscrambles every read for anyone with normal file access. LUKS only protects the disk while it is closed.
</details>

<details>
<summary>2. Where does the unscrambled data live while a LUKS disk is open?</summary>

Nowhere on the disk. `/dev/mapper/<name>` is a device-mapper target: the kernel's `dm-crypt` unscrambles each block as it is read and scrambles it as it is written. Nothing unscrambled is ever stored.
</details>

<details>
<summary>3. Why does disk encryption use the XTS mode?</summary>

XTS scrambles each sector on its own, using the sector's position on the disk. The kernel can rewrite one sector without reading or rewriting any other sector.
</details>

<details>
<summary>4. You add a second passphrase with <code>luksAddKey</code>. What does <code>cryptsetup</code> write to the disk?</summary>

Only a new keyslot in the header: a copy of the master key, locked with the new passphrase. The data area is not touched.
</details>

<details>
<summary>5. You remove a colleague's passphrase with <code>luksKillSlot</code>. Do you need to encrypt the disk again?</summary>

No. Only their keyslot is destroyed. The master key and the data stay the same, and the other passphrases still work.
</details>

<details>
<summary>6. You opened a LUKS disk as <code>secure_vault</code>. Which device do you format with <code>mkfs.ext4</code>, and why?</summary>

`/dev/mapper/secure_vault`. Formatting the raw disk, for example `/dev/vdb`, writes over the LUKS header and keyslots, and no passphrase can open the disk after that.
</details>

<details>
<summary>7. <code>cryptsetup close secure_vault</code> fails because the device is busy. What do you do?</summary>

Unmount the filesystem first with `umount`. If something still holds it, find the process with `lsof` or `fuser -mv`, stop it, then run `close` again.
</details>

<details>
<summary>8. A thief copies your closed LUKS disk and runs <code>xxd</code> on it. What can they read?</summary>

Only the header: the `LUKS` magic bytes, the version, the cipher and the keyslot layout. The data area looks like random noise, with no file names, sizes or contents.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-010-module-03-playground
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-004-lab-012
```

Then run `astrona list` again:

```sh
astrona list
```

Neither the playground nor the mission should be in the list any more. You can start the playground again at any time with the `astrona run` command from the module's landing page. It always starts clean.
