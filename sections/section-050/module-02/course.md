# Network Automount Maps & Tuning

The master map tells `autofs` *where* to watch. The secondary map file tells it *what* to do when a trigger fires. This is where you define the dynamic routing maps to connect your local folders to foreign warehouses across the network.

If your `/etc/auto.master` contains the line `/net-data /etc/auto.netdata`, you must create and configure `/etc/auto.netdata`.

## Writing Sub-Maps

A standard sub-map entry connects a local key (the directory name requested) to a remote target, passing necessary mount options in between.

```text
shared_docs   -rw,soft,intr   192.168.1.50:/exports/documents
```

If a user executes `cd /net-data/shared_docs`, `autofs` catches the request. It looks in `auto.netdata`, finds the `shared_docs` key, and instantly executes an NFS mount of `192.168.1.50:/exports/documents` directly onto `/net-data/shared_docs`. The `-rw,soft,intr` section passes standard safety parameters to the underlying NFS `mount` command.

### The Trigger Trap: Do Not Pre-Create Folders

A common, fatal mistake engineers make with `autofs` is manually creating the target directory.

If you run `mkdir /net-data/shared_docs`, you break the system. `autofs` works by intercepting the kernel exception when someone requests a path that *does not exist*. If the directory already exists as an empty folder on the local disk, the kernel just returns the empty folder. It never triggers `autofs`.

The directory must not exist. `autofs` will dynamically create it in memory at the exact moment of the mount, and destroy it when the mount times out.

## Scaling with Wildcards and Variables

Writing a single line for every network share works for five shares, but it fails for five hundred user home directories. `autofs` supports wildcards to dynamically map requests.

Consider a scenario where an NFS server exports hundreds of home directories at `10.0.0.10:/home/`. You want a user typing `cd /net-data/alice` to automatically mount Alice's remote folder.

You configure your sub-map like this:

```text
*   -rw,soft,intr   10.0.0.10:/home/&
```

The asterisk `*` is the wildcard key. It matches any directory name requested inside `/net-data`.

The ampersand `&` is the variable. It represents whatever text matched the wildcard.

If someone requests `/net-data/bob`, the wildcard catches "bob". `autofs` takes the string "bob", injects it where the ampersand is, and mounts `10.0.0.10:/home/bob`. One line of configuration dynamically scales to an infinite number of remote directories.

## Self-Check and Verification

To prove you can architect dynamic network maps:

1. Configure an NFS server to export two separate directories: `/export/engineering` and `/export/marketing`.
2. On a client machine, configure `/etc/auto.master` to watch `/mnt/departments` using a map file named `/etc/auto.departments`.
3. Write the `/etc/auto.departments` map to link the local keys `eng` and `mkt` to their respective NFS exports, applying `ro,soft` mount options.
4. Reload the `autofs` service.
5. Execute `ls -l /mnt/departments/eng`. Verify the directory is instantly mounted, the remote files are visible, and `mount | grep nfs` confirms the connection.
6. Wait for the idle timeout to expire and verify the mount automatically detaches.
