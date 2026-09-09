# Part 1 — Discovering Exports & Writing a Sub-map

> Prerequisite: [Module landing page](./course.md). Next: [Part 2 — Idle Unmount & Wildcards](./course-02-wildcards-and-idle-unmount.md).

Module 1 covered the master map — *which* directory `autofs` watches. This part is the sub-map it points at — *what* to mount when a request lands on a key underneath — pointed at a real NFS server instead of the previous module's local bind mount.

## Discovering the exports

Before mapping anything, confirm what the server offers and that your client is allowed. `showmount -e <server>` asks the server's `mountd` for its export list and the networks each is available to — the same query an NFS client makes internally before the first mount, just run by hand.

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
- **options** — `-fstype=nfs,ro,soft`. The filesystem type and mount options, comma-joined, no spaces. Here: an NFS mount, read-only, `soft` (give up with an I/O error rather than hang forever if the server vanishes — safe on a read-only mount, since there is no pending write to lose).
- **target** — `nfs:/export/eng`. `host:/path` for the NFS export.

Older examples add `intr` to the options. It has been a no-op since Linux 2.6.25 — the kernel already lets fatal signals interrupt NFS waits — so leave it out.

With the master map watching `/mnt/dep` and pointing at `/etc/auto.dep`, you create `/etc/auto.dep` with the keys, reload, and then a plain `ls` on a key triggers the NFS mount through the exact same trap-and-resume path Module 1's Part 1 walked through — only the thing the daemon runs at the end differs (`mount -t nfs` instead of a bind mount).

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
> The `ls` on the `eng` key triggered `autofs`, which ran the NFS mount defined on that line. `mount` shows both the `autofs` trigger zone and the live `nfs4` mount. `mkt` is mapped too but stays unmounted until something asks for `/mnt/dep/mkt` — each key is looked up and mounted independently, not as a batch.

> *A sub-map key only costs a mount the moment something asks for it by name — listing ten keys in the file mounts nothing until ten separate requests arrive.*

## Reference

- `man showmount` — the export-query tool used above; `-a` also lists who currently has what mounted.
- `man 5 nfs` — the full NFS mount-option reference, including `soft`/`hard`, `timeo`, and `retrans`, only briefly introduced here.
