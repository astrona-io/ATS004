# Ad-Hoc Mounting with SSHFS

Think of SSHFS as a personal bicycle courier. It is not designed to haul shipping containers of cargo across the country. It is designed to take a small package, securely hand it off to a rider, and deliver it exactly where you tell it to go, without needing permission from the city planners. It is fast to set up, requires zero infrastructure changes, and runs entirely in the background using the secure channels you already have.

When you need access to a remote folder immediately, configuring a dedicated file server is a waste of time. If you have SSH access to a machine, you already have everything you need to mount its filesystem locally.

## The FUSE Architecture

Linux filesystems traditionally live deep inside the kernel. The kernel handles the raw block devices, manages the memory buffers, and enforces the rules. To write a new filesystem driver historically meant writing kernel code. A bug in that code would bring down the entire server.

Filesystem in Userspace (FUSE) changes the rules. It allows regular users to create filesystems without touching the kernel. FUSE acts as a bridge. When a program tries to read a file from a FUSE mount, the kernel intercepts the request and hands it back up to a normal, user-space program to figure out the answer.

This is exactly how SSHFS works. When you run `sshfs user@remote:/path/to/files /mnt/local`, you start a background program on your local machine. You open a local mount point. When you list the files in `/mnt/local`, the kernel asks the local SSHFS process what is there. The SSHFS process sends an encrypted message over your SSH connection to the remote server, asks it to list the directory, gets the answer, and passes it back to the kernel.

### The Cost of Context Switching

Because the bicycle courier has to cross the bridge between user-space and kernel-space for every single operation, FUSE filesystems carry overhead. This crossing is called a context switch.

If you read a massive continuous file over SSHFS, the performance is decent. However, if you compile a large codebase with thousands of tiny files over SSHFS, performance drops. Every file open, read, and close triggers a context switch. SSHFS is for ad-hoc access and development, not high-performance production workloads.

## Mounting and Securing SSHFS

Mounting a remote path requires the `sshfs` command. The syntax mirrors `scp` or `rsync`.

```bash
sshfs alice@db-server:/var/log/app /mnt/app-logs
```

By default, FUSE mounts are heavily restricted. If the user `alice` mounts a directory, only `alice` can see it. Even the `root` user on the local machine gets an "Access denied" error if they try to read `/mnt/app-logs`. The kernel blocks everyone else to prevent security leaks.

Sometimes you need other local users, or an application running under a different service account, to read the mounted files. You bypass this restriction using the `-o allow_other` flag.

```bash
sshfs -o allow_other alice@db-server:/var/log/app /mnt/app-logs
```

This tells the kernel to let other users access the mount point. But there is a catch. The local kernel enforces the permissions it sees. If the remote files are owned by user ID 1000, the local kernel checks if the local user requesting access is user ID 1000. It doesn't care about usernames, only numbers.

If you want the remote filesystem to enforce the access rules based on who you logged in as over SSH, you add `default_permissions`. This forces the local kernel to actually check the permissions reported by the remote server before granting access.

```bash
sshfs -o allow_other,default_permissions alice@db-server:/var/log/app /mnt/app-logs
```

When you are finished with the mount, you unmount it like any other disk using `umount`.

```bash
umount /mnt/app-logs
```

## Self-Check and Verification

To prove your SSHFS setup is working as intended:

1. Connect to a remote server using `sshfs` and mount a directory.
2. Run `mount | grep fuse` to verify the filesystem is active and see the options applied.
3. Switch to a different local user account and attempt to read the mount point. Confirm it is blocked.
4. Unmount, remount with `-o allow_other`, and test access again as the second user.
5. Use `umount` to cleanly detach the filesystem and verify the mount point is empty.
