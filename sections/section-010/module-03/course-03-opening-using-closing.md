# Part 3 — Opening, Using, Closing & What's Visible Outside

> Prerequisite: [Part 2 — Creating a Container & Its Keyslots](./course-02-creating-a-container-and-keyslots.md). Next: [Module landing page](./course.md).

Part 2 built the container and its keyslots. This part covers the daily-driver operations — opening the device to actually use it, and what someone examining the raw bytes without a passphrase can and cannot learn.

## Opening, using, and closing the vault

`cryptsetup open <device> <name>` prompts for a passphrase, tries it against every keyslot in turn, and on the first match creates `/dev/mapper/<name>`. You then treat that path as the disk: `mkfs.ext4 /dev/mapper/<name>`, `mount`, use it, `umount`, and finally `cryptsetup close <name>`.

Formatting must target the mapped device, never the raw one. Running `mkfs.ext4 /dev/vdb` now would overwrite the LUKS header and keyslots directly — not "encrypt them again," but destroy the only structures that know how to recover the master key. There is no passphrase that fixes an overwritten header.

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
> While open, `secure_vault` behaves exactly like a plain disk and `df` shows the ext4 filesystem mounted through it. After `close`, the mapper entry is gone and the data on `/dev/vdb` is inert encrypted bytes again. `close` fails with "Device secure_vault is busy" if you skip the `umount` — the device-mapper target cannot be torn down while the filesystem above it still has it open, for the same reason you cannot `rmmod` a driver a running process depends on.

## What the locked disk looks like from outside

With the device closed, someone who copies `/dev/vdb` gets the LUKS header — a small, clearly labelled structure — followed by the encrypted data region, which is statistically indistinguishable from random noise. No filenames, no sizes, no content. This isn't obfuscation; it's the direct, provable consequence of Part 1's model — nothing decrypted was ever written to this device, only the header (which is *meant* to be readable, so any LUKS-aware tool can identify the cipher and keyslots to attempt) and AES-XTS output.

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
> - **A lost passphrase means lost data.** If no keyslot's passphrase is known and you have no header backup, the master key cannot be recovered — Part 2's model means there is no back door, by design. Record passphrases in a real secret store and consider `cryptsetup luksHeaderBackup`.
> - **Formatting the raw device after LUKS.** `mkfs.ext4 /dev/vdb` (instead of `/dev/mapper/...`) overwrites the LUKS header and keyslots. The passphrase becomes useless. Always act on the `/dev/mapper/` name once the device is open.
> - **`close` while still mounted or in use.** `cryptsetup close` fails with "device is busy" if the filesystem is mounted or a process holds a file open. `umount` (and clear any process holding a file open, as in Module 1) before closing.
> - **Treating LUKS as protection for a live system.** Once the volume is open and mounted, its contents are readable to anyone with normal filesystem access. LUKS only helps when the device is closed — Part 1's threat model, restated as an operational rule.

> *Everything this part demonstrates is a consequence of Part 1's mapping model: `open` recovers the master key and stands up a transform, `close` tears the transform down, and what's left on disk when it's down is exactly the header plus noise — never a "your data, hidden" state, because your data in cleartext form never touches the disk at all.*

## Reference

- `man 8 cryptsetup` — `luksHeaderBackup` / `luksHeaderRestore`, essential before any risky header operation on a real (non-playground) device.
- `man 1 xxd` — `-s` (seek) and `-l` (length) as used above; useful for any "what's actually on this block device" inspection, encrypted or not.
