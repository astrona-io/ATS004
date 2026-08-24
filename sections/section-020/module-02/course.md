# Enterprise Sharing with NFS

If SSHFS is a bicycle courier for quick, ad-hoc deliveries, the Network File System (NFS) is a dedicated cargo pipeline. It is built directly into the kernel for performance. It is designed to share massive volumes of data continuously to hundreds of servers at once. You don't use NFS for a temporary fix; you use it to build your infrastructure.

NFS operates on a strict client-server model. The server explicitly lists what directories it is willing to share, and the clients request permission to attach those directories.

## The Server Side: Defining Exports

The NFS server controls access through a single file: `/etc/exports`. This file dictates exactly which local paths are exposed, which external IP addresses can access them, and what permissions those clients receive.

A typical export entry looks like this:

```text
/data/shared   192.168.1.0/24(rw,sync,no_subtree_check)
```

This line tells the NFS server to expose `/data/shared` to any machine on the `192.168.1.0/24` subnet. The options in parentheses dictate the rules of engagement.

The `rw` flag grants read and write access. You use `ro` for read-only access.

The `sync` flag forces the NFS server to confirm that data is physically written to the disk before telling the client the operation was successful. This prevents data corruption if the server suddenly loses power. The alternative, `async`, is faster but risks data loss because the server replies "done" while the data is still sitting in memory.

The `no_subtree_check` flag is a standard optimization. If you only export a subdirectory (a subtree) of a larger filesystem, the server normally has to check every incoming request to ensure the client hasn't somehow navigated outside that specific folder. This check causes massive performance hits when files are renamed. Disabling it speeds up the server and improves reliability.

When you modify `/etc/exports`, the server does not immediately notice. You must force the NFS service to re-read the file using `exportfs`.

```bash
exportfs -arv
```

The `-a` flag tells the command to process all entries in the file. The `-r` flag forces a re-export, syncing the active state with the configuration file. The `-v` flag makes the output verbose, so you can clearly see what the server just did.

## The Client Side: Safe Mounting

Before a client attempts to mount a share, it is good practice to ask the server what it has available. You query the server's export list using `showmount`. The `-e` flag stands for "exports".

```bash
showmount -e 192.168.1.100
```

Once you confirm the share exists and your client's IP is allowed, you mount it using the standard `mount` command, specifying the filesystem type as `nfs`.

```bash
mount -t nfs 192.168.1.100:/data/shared /mnt/nfs-data
```

### Protecting the Client

NFS is designed around the assumption that the network is reliable. By default, an NFS mount is a "hard" mount. If the server goes offline or the network cable is cut, the client will retry the connection forever. Any application trying to read or write to that mount point will freeze entirely. You cannot even kill the frozen process with `kill -9` because it is stuck waiting on the kernel, which is stubbornly waiting on the network.

In unreliable environments, you protect your client by using safety parameters. You pass these options using the `-o` flag.

```bash
mount -t nfs -o soft,intr 192.168.1.100:/data/shared /mnt/nfs-data
```

The `soft` flag tells the kernel to eventually give up. If the server doesn't respond after a certain number of retries, the kernel returns an I/O error to the application instead of hanging forever. The application might crash, but the system itself stays responsive.

The `intr` flag (interruptible) allows signals to interrupt file operations. If a terminal gets stuck trying to list a dead NFS mount, the `intr` flag ensures that pressing `Ctrl+C` actually works to abort the request. Note that modern Linux kernels handle interruptions better by default, but explicitly stating these flags provides clear intent.

## Self-Check and Verification

To prove your NFS environment is robust:

1. Configure a directory in `/etc/exports` with `ro,sync,no_subtree_check` and apply it using `exportfs -arv`.
2. From a separate machine, verify visibility of the export using `showmount -e <server-ip>`.
3. Mount the share using `mount -t nfs` and attempt to write a file to verify the read-only restriction holds.
4. Remount the share adding `-o soft` parameters.
5. While actively reading a large file from the mount, cleanly disconnect the server from the network and verify the client process eventually reports an error instead of hanging indefinitely.
