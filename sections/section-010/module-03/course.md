# Under Lock and Key: Securing Data-at-Rest with LUKS

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-010/module-03/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-010/module-03/playground
> astrona destroy section-010-module-03-playground
> ```

Filesystem permissions protect data only while the operating system that enforces them is running. Pull the disk out and read it on another machine, or clone a cloud volume offline, and the permissions are irrelevant — the bytes are right there. Protecting data **at rest**, against someone who has the storage but not your running system, needs encryption on the disk itself.

On Linux the standard tool for this is **LUKS** (Linux Unified Key Setup): full-block-device encryption built into the kernel. This chapter covers what LUKS defends against, how its keys are arranged, and the `cryptsetup` commands to create, open, use, and close an encrypted volume.

## Learning objectives

After this module you can:

- Describe the offline / data-at-rest threat that LUKS addresses and what it does not protect against.
- Create a LUKS container on a block device with `cryptsetup luksFormat`.
- Explain the roles of the master key and the keyslots, and add a second passphrase with `luksAddKey`.
- Open a LUKS device to a `/dev/mapper/` name, put a filesystem on the *mapped* device, mount it, then unmount and `close` it.
- Predict what the raw device shows to someone without the passphrase.

## Before you start

You should know how to format and mount a filesystem (`mkfs.ext4`, `mount`, `umount`) from the earlier modules, and be comfortable with `sudo`.

The linked playground gives you an Ubuntu server VM with passwordless `sudo`, the `cryptsetup` tool, the `dm_crypt` kernel module loaded, and one spare 2 GB raw disk (commonly `/dev/vdb`) wiped clean on every boot. Run the command blocks below in that VM after connecting with `astrona ssh astro-section-010-module-03-playground`. The examples encrypt the whole disk `/dev/vdb`; on a real system you would usually encrypt a partition such as `/dev/vdb1` instead, but the commands are identical.

## What LUKS protects against

LUKS encrypts every block before it reaches the physical media and decrypts it on the way back, using a key derived from a passphrase you supply. It defends against:

- a disk removed from a server and read elsewhere,
- an offline copy or snapshot of a cloud volume,
- a discarded or RMA'd drive that still holds readable data.

It does **not** protect a running system where the volume is already unlocked and mounted — at that point the kernel is decrypting reads for anyone with filesystem access. Nor does it help if the passphrase is weak or written on a sticky note. LUKS is one layer, aimed squarely at the "someone has the disk" case.

## The mental model: lock the disk, work through a mapping

You never write a filesystem onto the locked device directly. Instead:

1. `cryptsetup luksFormat` writes a **LUKS header** to the start of the device and marks the rest as an encrypted region.
2. `cryptsetup open` asks for the passphrase and, if it checks out, creates a decrypted **virtual device** under `/dev/mapper/`. Reads and writes to that virtual device are encrypted and decrypted on the fly by the kernel's `dm-crypt` (device-mapper crypt) layer.
3. You format and mount the `/dev/mapper/` device like any normal disk.
4. `cryptsetup close` removes the virtual device. The physical disk is back to being an opaque encrypted blob.

> As an analogy: the locked device is a heavy safe. `open` is spinning the dial to the right combination, which lets a service window (`/dev/mapper/secure_vault`) appear that you can pass documents through. `close` shuts the safe and the window disappears. The analogy breaks down because the "documents" (your filesystem) are never physically inside anything — `dm-crypt` transforms each block as it passes through the window, and nothing readable is ever stored.

## Creating a LUKS container

`cryptsetup luksFormat <device>` initializes the encryption. It overwrites the start of the device, so it demands you type `YES` in capitals, then asks for a passphrase twice. On current systems it creates a **LUKS2** header by default.

> [!TIP]
> **Try it — format and inspect the header**
>
> ```sh
> sudo cryptsetup luksFormat /dev/vdb
> sudo cryptsetup luksDump /dev/vdb
> ```
>
> `luksFormat` prompts:
>
> ```text
> WARNING!
> ========
> This will overwrite data on /dev/vdb irrevocably.
>
> Are you sure? (Type 'yes' in capital letters): YES
> Enter passphrase for /dev/vdb:
> Verify passphrase:
> ```
>
> `luksDump` then prints something like:
>
> ```text
> LUKS header information
> Version:        2
> ...
> Data segments:
>   0: crypt
>         offset: 16777216 [bytes]
>         cipher: aes-xts-plain64
> Keyslots:
>   0: luks2
>         Key:        512 bits
>         PBKDF:      argon2id
> ```
>
> The header records the cipher (`aes-xts-plain64`) and one active keyslot (`0`) holding your passphrase. The data region starts 16 MiB in, after the header. No filesystem exists yet — that comes after you open the device.
>
> *Scripting note:* to avoid the prompts you can pipe the passphrase in:
> `printf 'my-pass' | sudo cryptsetup luksFormat /dev/vdb --batch-mode --key-file=-`.

## Master key and keyslots

Your passphrase does not encrypt your data directly. It is too short and too guessable. Instead, `luksFormat` generates a long random **master key** and it is the master key that encrypts every data block.

The master key itself is then stored — encrypted — in a **keyslot** in the header. Your passphrase is run through a deliberately slow key-derivation function (Argon2id on LUKS2) and the result encrypts the master key into keyslot 0. LUKS2 has room for many keyslots, so several different passphrases can each unlock the *same* master key.

That is how you grant a second person access without sharing your passphrase: `cryptsetup luksAddKey <device>` authenticates with an existing passphrase, then encrypts the master key under a new one and stores it in the next free slot.

> [!TIP]
> **Try it — add a second passphrase**
>
> ```sh
> sudo cryptsetup luksAddKey /dev/vdb
> sudo cryptsetup luksDump /dev/vdb | grep -A1 '^  [0-9]*: luks2'
> ```
>
> Expect something like:
>
> ```text
> Enter any existing passphrase:
> Enter new passphrase for key slot:
> Verify passphrase:
>
>   0: luks2
>         Key:        512 bits
>   1: luks2
>         Key:        512 bits
> ```
>
> There are now two keyslots. Either passphrase decrypts its slot to recover the one shared master key, so both unlock the same data. Removing a person's access is `cryptsetup luksKillSlot /dev/vdb 1`.

## Opening, using, and closing the vault

`cryptsetup open <device> <name>` prompts for a passphrase and, on success, creates `/dev/mapper/<name>`. You then treat that path as the disk: `mkfs.ext4 /dev/mapper/<name>`, `mount`, use it, `umount`, and finally `cryptsetup close <name>`.

Formatting must target the mapped device, never the raw one. Running `mkfs.ext4 /dev/vdb` now would overwrite the LUKS header and make the data permanently unrecoverable even with the right passphrase.

> [!TIP]
> **Try it — open, write, close**
>
> ```sh
> sudo cryptsetup open /dev/vdb secure_vault
> ls -l /dev/mapper/secure_vault
> sudo mkfs.ext4 /dev/mapper/secure_vault
> sudo mkdir -p /mnt/vault
> sudo mount /dev/mapper/secure_vault /mnt/vault
> echo "top secret" | sudo tee /mnt/vault/notes.txt
> df -h /mnt/vault
> sudo umount /mnt/vault
> sudo cryptsetup close secure_vault
> ls /dev/mapper/
> ```
>
> Expect something like:
>
> ```text
> lrwxrwxrwx 1 root root 7 Aug 29 12:00 /dev/mapper/secure_vault -> ../dm-0
> ...
> Filesystem                Size  Used Avail Use% Mounted on
> /dev/mapper/secure_vault  1.9G   24K  1.8G   1% /mnt/vault
> ...
> (after close: only 'control' remains under /dev/mapper/)
> ```
>
> While open, `secure_vault` behaves exactly like a plain disk and `df` shows the ext4 filesystem mounted through it. After `close`, the mapper entry is gone and the data on `/dev/vdb` is inert encrypted bytes again. `close` fails with "Device secure_vault is busy" if you skip the `umount` — release the filesystem first.

## What the locked disk looks like from outside

With the device closed, someone who copies `/dev/vdb` gets the LUKS header — a small, clearly labelled structure — followed by the encrypted data region, which is statistically indistinguishable from random noise. No filenames, no sizes, no content.

> [!TIP]
> **Try it — read the raw bytes**
>
> `xxd` is a hex viewer: `-l` limits how many bytes it dumps, `-s` seeks to a byte offset first.
>
> ```sh
> sudo xxd -l 96 /dev/vdb
> sudo xxd -s 20000000 -l 64 /dev/vdb
> ```
>
> Expect something like:
>
> ```text
> 00000000: 4c55 4b53 babe 0002 ...   LUKS............     <-- 'LUKS' magic + version
> ...
> 01312d00: 9c3e a71f 4b02 ...        .>..K...........     <-- deep in the data area: noise
> ```
>
> The first four bytes spell `LUKS` and the header advertises the version and cipher — that part is meant to be readable so tools know how to unlock it. Everything in the data region is high-entropy: nothing about your files is visible without the passphrase.

> [!WARNING]
> **Common pitfalls**
>
> - **A lost passphrase means lost data.** If no keyslot's passphrase is known and you have no header backup, the master key cannot be recovered. There is no reset. Record passphrases in a real secret store and consider `cryptsetup luksHeaderBackup`.
> - **Formatting the raw device after LUKS.** `mkfs.ext4 /dev/vdb` (instead of `/dev/mapper/...`) overwrites the LUKS header and keyslots. The passphrase becomes useless. Always act on the `/dev/mapper/` name once the device is open.
> - **`close` while still mounted or in use.** `cryptsetup close` fails with "device is busy" if the filesystem is mounted or a process holds a file open. `umount` (and clear any process, as in the first module) before closing.
> - **Treating LUKS as protection for a live system.** Once the volume is open and mounted, its contents are readable to anyone with normal access. LUKS only helps when the device is closed.
