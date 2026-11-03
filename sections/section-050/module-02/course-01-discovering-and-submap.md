# Discovering Exports and Writing a Map

The master map says which directory `autofs` guards. The map file it points at says what to dock when a request lands on a key under that directory. Here the hold sits on another ship, an NFS server, instead of on your own.

## Discovering the exports

Before you map anything, ask what the server offers and whether your ship may dock it. `showmount -e <server>` asks the server's `mountd` for its export list and the networks that may use each export. An NFS client makes the same query internally before its first mount.

<!-- astrona:playground:renew -->

### See it in your playground

On `client`, list the exports of the server called `nfs`:

```sh
showmount -e nfs
```

Expect something like this:

```text
Export list for nfs:
/export/eng 10.10.50.0/24
/export/mkt 10.10.50.0/24
```

Both directories are exported to `10.10.50.0/24`, which includes `client` (10.10.50.5). These are the targets the map will point to.

## Writing a map with explicit keys

A map file has one line per key:

```text
eng   -fstype=nfs,ro,soft   nfs:/export/eng
```

- **key**: `eng`. The name under the managed directory. A request for `/mnt/dep/eng` matches this line.
- **options**: `-fstype=nfs,ro,soft`. The filesystem type and the mount options, joined with commas and no spaces. This one is NFS, read-only, and `soft`. A `soft` mount gives up with an error if the server vanishes, instead of waiting forever. That is safe on a read-only mount, because no write is waiting.
- **target**: `nfs:/export/eng`, written as `host:/path`.

Older examples add `intr` to the options. It has done nothing since Linux 2.6.25, so leave it out.

Save this as `/etc/auto.dep` (a file under `/etc` is saved with `sudo`, for example `sudo nano /etc/auto.dep`):

```text
eng  -fstype=nfs,ro,soft  nfs:/export/eng
mkt  -fstype=nfs,ro,soft  nfs:/export/mkt
```

Apply it. The master line puts `/mnt/dep` under `autofs` control with a 15 second timeout, and the reload makes the daemon read both files:

```sh
echo '/mnt/dep  /etc/auto.dep  --timeout=15' | sudo tee -a /etc/auto.master
sudo systemctl reload autofs
```

Then check the result:

```sh
ls /mnt/dep/eng
cat /mnt/dep/eng/eng-readme.txt
mount | grep /mnt/dep
```

Expect something like this:

```text
eng-readme.txt
engineering shared file

/etc/auto.dep on /mnt/dep type autofs (...)
nfs:/export/eng on /mnt/dep/eng type nfs4 (ro,relatime,...,soft,...)
```

The `ls` knocked on the hatch. The daemon ran the NFS mount from that line. `mount` shows the `autofs` trigger and the live `nfs4` mount. The `mkt` key stays undocked until something asks for `/mnt/dep/mkt`. Each key is looked up and mounted on its own.

## Common pitfalls

> [!WARNING]
> - **Spaces in the options field.** `-fstype=nfs, ro, soft` breaks the line. Join the options with commas only.
> - **Forgetting the reload.** The daemon does not watch files. Run `sudo systemctl reload autofs` after every edit.
> - **Creating the key directory by hand.** `mkdir /mnt/dep/eng` stops the trap from firing, and the NFS mount never happens.
> - **Adding `intr`.** It has been a no-op since Linux 2.6.25. Leave it out.
> - **Expecting every key to mount at once.** A key costs a mount only when something asks for it by name.
