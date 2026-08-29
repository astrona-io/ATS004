# Network Automount Maps & Tuning

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-050/module-02/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-050/module-02/playground
> astrona destroy section-050-module-02-playground
> ```

The master map says *which* directory `autofs` watches. The sub-map it points at says *what to mount* when a request comes in. This module covers sub-map syntax — mapping a requested name to a remote NFS export with mount options — the idle unmount in action, and wildcard entries that cover many targets with one line.

## Learning objectives

After this module you can:

- Query an NFS server's exports with `showmount -e`.
- Write a sub-map entry that maps a key to an NFS target with mount options.
- Trigger an on-demand NFS mount and confirm it with `mount`.
- Observe the idle-timeout unmount.
- Write a wildcard sub-map using `*` and `&` to cover many targets with one line.

## Before you start

You need the previous module's material: how `autofs` intercepts access, the `/etc/auto.master` line format, and `systemctl reload autofs`. Familiarity with NFS exports and `mount -t nfs` from Section 020 helps.

The linked playground gives you two VMs on a private network: `client` (where every command below runs — `astrona ssh client`) with `autofs` running and `/etc/auto.master` backed up to `/etc/auto.master.orig`, and `nfs` (10.10.50.10) exporting `/export/eng` and `/export/mkt` read-only, each holding one file. `client` resolves `nfs` from `/etc/hosts`.

## Discovering the exports

Before mapping anything, confirm what the server offers and that your client is allowed. `showmount -e <server>` lists a server's exports and the networks each is available to.

> [!TIP]
> **Try it — list the server's exports**
>
> ```sh
> showmount -e nfs
> ```
>
> Expect something like:
>
> ```text
> Export list for nfs:
> /export/eng 10.10.50.0/24
> /export/mkt 10.10.50.0/24
> ```
>
> Both directories are exported to `10.10.50.0/24`, which includes `client` (10.10.50.5). These are the targets the sub-map will connect to.

## Writing a sub-map with explicit keys

A sub-map file has one line per key:

```text
eng   -fstype=nfs,ro,soft   nfs:/export/eng
```

- **key** — `eng`. The subdirectory name under the managed directory. A request for `/mnt/dep/eng` matches this line.
- **options** — `-fstype=nfs,ro,soft`. The filesystem type and mount options, comma-joined, no spaces. Here: an NFS mount, read-only, `soft` (give up with an I/O error rather than hang forever if the server vanishes — safe on a read-only mount).
- **target** — `nfs:/export/eng`. `host:/path` for the NFS export.

Older examples add `intr` to the options. It has been a no-op since Linux 2.6.25 — the kernel already lets fatal signals interrupt NFS waits — so leave it out.

With the master map watching `/mnt/dep` and pointing at `/etc/auto.dep`, you create `/etc/auto.dep` with the keys, reload, and then a plain `ls` on a key triggers the NFS mount.

> [!TIP]
> **Try it — map two exports and trigger one**
>
> ```sh
> echo '/mnt/dep  /etc/auto.dep  --timeout=15' | sudo tee -a /etc/auto.master
> sudo tee /etc/auto.dep <<'EOF'
> eng  -fstype=nfs,ro,soft  nfs:/export/eng
> mkt  -fstype=nfs,ro,soft  nfs:/export/mkt
> EOF
> sudo systemctl reload autofs
> ls /mnt/dep/eng
> cat /mnt/dep/eng/eng-readme.txt
> mount | grep /mnt/dep
> ```
>
> Expect something like:
>
> ```text
> eng-readme.txt
> engineering shared file
>
> /etc/auto.dep on /mnt/dep type autofs (...)
> nfs:/export/eng on /mnt/dep/eng type nfs4 (ro,relatime,...,soft,...)
> ```
>
> The `ls` on the `eng` key triggered `autofs`, which ran the NFS mount defined on that line. `mount` shows both the `autofs` trigger zone and the live `nfs4` mount. `mkt` is mapped too but stays unmounted until something asks for `/mnt/dep/mkt`.

## The idle unmount

The `--timeout=15` from the master-map line applies to everything under `/mnt/dep`. With nothing open on `/mnt/dep/eng` and no shell inside it, `autofs` unmounts it after about 15 seconds. Real deployments use longer values — the section objective mentions 300 seconds; 15 just makes it watchable.

> [!TIP]
> **Try it — watch it detach**
>
> ```sh
> cd ~
> sleep 20
> mount | grep /mnt/dep
> ```
>
> Expect something like:
>
> ```text
> /etc/auto.dep on /mnt/dep type autofs (...)
> ```
>
> Only the `autofs` line remains — the `nfs4` mount is gone. Accessing `/mnt/dep/eng` again re-mounts it on the spot. If the `nfs4` line is still there, a process still has the mount busy; `cd` out of it and wait again.

## Wildcards: one line for many targets

Two departments need two lines. Hundreds of user home directories would need hundreds — unmanageable. A wildcard entry maps any key to a target computed from the key's name:

```text
*   -fstype=nfs,ro,soft   nfs:/export/&
```

- `*` as the key matches **any** name requested under the managed directory.
- `&` in the target is replaced with **the text that `*` matched**.

So a request for `/mnt/dep/mkt` makes `*` match `mkt`, and `&` expands to `mkt`, mounting `nfs:/export/mkt`. One line covers every current and future `/export/<name>` the server has.

> [!TIP]
> **Try it — replace the explicit keys with a wildcard**
>
> ```sh
> sudo tee /etc/auto.dep <<'EOF'
> *  -fstype=nfs,ro,soft  nfs:/export/&
> EOF
> sudo systemctl reload autofs
> ls /mnt/dep/mkt
> cat /mnt/dep/mkt/mkt-readme.txt
> mount | grep /mnt/dep
> ```
>
> Expect something like:
>
> ```text
> mkt-readme.txt
> marketing shared file
>
> nfs:/export/mkt on /mnt/dep/mkt type nfs4 (ro,...)
> ```
>
> `mkt` was never named in the map, yet it mounted — `*` caught the name and `&` built `nfs:/export/mkt`. Requesting `/mnt/dep/eng` would work the same way. Roll everything back with `sudo cp /etc/auto.master.orig /etc/auto.master`, `sudo rm /etc/auto.dep`, `sudo systemctl reload autofs`.

> [!WARNING]
> **Common pitfalls**
>
> - **Pre-creating the key directory.** `mkdir /mnt/dep/eng` makes the path exist, so the kernel never signals `autofs` and the NFS mount never happens. Let `autofs` create and remove those directories.
> - **Forgetting to reload.** `autofs` does not re-read `/etc/auto.master` or the sub-map on its own. `sudo systemctl reload autofs` after every edit.
> - **Spaces inside the options field.** `-fstype=nfs, ro, soft` breaks parsing. Write the options comma-joined with no spaces: `-fstype=nfs,ro,soft`.
> - **Adding `intr`.** It has done nothing since Linux 2.6.25. Use `soft` with a sane `timeo`/`retrans` if you need reads to fail fast; otherwise the default is fine.
> - **A wildcard that does not match the server's layout.** `nfs:/export/&` only works if every export really is `/export/<key>`. If names differ, you need explicit keys or a smarter map.
> - **A shell left inside an automounted directory.** It keeps the mount busy so the idle timeout never fires. `cd` out when you are done looking.
