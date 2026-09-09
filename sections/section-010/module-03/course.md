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

On Linux the standard tool for this is **LUKS** (Linux Unified Key Setup): full-block-device encryption built into the kernel. This module covers what LUKS defends against, how its keys are arranged, and the `cryptsetup` commands to create, open, use, and close an encrypted volume.

## How this module is organised

1. **[Part 1 — The LUKS Model: Locking a Disk](./course-01-the-luks-model.md)** — the threat LUKS actually addresses, the locked/mapped mental model, and why disk encryption uses AES-XTS rather than a stream-cipher mode.
2. **[Part 2 — Creating a Container & Its Keyslots](./course-02-creating-a-container-and-keyslots.md)** — `luksFormat`, and the master-key-plus-keyslots mechanism that lets multiple passphrases share one encrypted device.
3. **[Part 3 — Opening, Using, Closing & What's Visible Outside](./course-03-opening-using-closing.md)** — the daily `open`/`mkfs`/`mount`/`umount`/`close` cycle, and what a raw byte-level look at a closed device actually shows.

## Learning objectives

After this module you can:

- Describe the offline / data-at-rest threat that LUKS addresses and what it does not protect against.
- Explain the locked/mapped device-mapper model and why AES-XTS is the cipher mode used for block storage.
- Create a LUKS container on a block device with `cryptsetup luksFormat`.
- Explain the roles of the master key and the keyslots, and add a second passphrase with `luksAddKey` without touching the data region.
- Open a LUKS device to a `/dev/mapper/` name, put a filesystem on the *mapped* device, mount it, then unmount and `close` it.
- Predict what the raw device shows to someone without the passphrase, and why.

## Before you start

You should know how to format and mount a filesystem (`mkfs.ext4`, `mount`, `umount`) from the earlier modules, and be comfortable with `sudo`.

The linked playground gives you an Ubuntu server VM with passwordless `sudo`, the `cryptsetup` tool, the `dm_crypt` kernel module loaded, and one spare 2 GB raw disk (commonly `/dev/vdb`) wiped clean on every boot. Run the command blocks in Parts 1–3 in that VM after connecting with `astrona ssh astro-section-010-module-03-playground`. The examples encrypt the whole disk `/dev/vdb`; on a real system you would usually encrypt a partition such as `/dev/vdb1` instead, but the commands are identical.
