# Chapter 5: Bridges Over the Wire: Remote Filesystems (SSHFS and NFS)

In modern infrastructure, storage is rarely locked inside a single physical chassis. Databases need centralized backups, microservices need shared configuration profiles, and web servers need to read the exact same directory of image assets. If every server had its own isolated hard drives, synchronizing data across a cluster would be an administrative nightmare. 

To break down these physical walls, we build cryptographic and high-performance network bridges. 

In this chapter, we will master two of the most popular remote storage protocols in the Linux ecosystem: **SSHFS** (Secure Shell Filesystem), a flexible user-space tool perfect for secure, ad-hoc connections, and **NFS** (Network File System), the enterprise workhorse designed for high-throughput, multi-client kernel-integrated sharing.

---

## The Courier and the Pipeline: Two Philosophies of Remote Storage

To understand the difference between SSHFS and NFS, let's use an office analogy. Imagine you are sitting at your desk, and you frequently need to read and update files located in a central archives building across town.

- **SSHFS** is like hiring a private bicycle courier. Whenever you need to read a file from the central vault, your courier securely rides their bicycle across town (via an encrypted SSH tunnel), grabs the file, and lays it on your desk. Because the courier uses the public streets and standard office security clearance (SSH ports and keys), you don't need to ask permission from the city council to build any special infrastructure. It is highly secure, fast to set up, and very flexible. However, because the courier has to ride back and forth for every single page, they can easily get overwhelmed if you ask them to carry a massive, multi-ton pile of crates all at once.
- **NFS** is like laying down a heavy-duty physical cargo pipeline directly between the archives building and your desk. Constructing this pipeline requires city planning, structural engineers, and explicit permissions (configuring server exports, ports, and subnets). It is not encrypted by default, so you must secure the path itself (private networks or VLANs). However, once the pipeline is live, massive quantities of cargo flow back and forth with almost zero friction. Multiple desks across the office can tap into this exact same pipeline, sharing the same files in real time.

---

## Under the Hood: User-Space vs. Kernel-Space Filesystems

The core difference between SSHFS and NFS lies in where the translation of filesystem requests takes place: the kernel or the user space.

### SSHFS and FUSE: The User-Space Courier
Traditionally, writing a filesystem driver required writing complex, low-level C code that runs inside the Linux kernel. A single bug or memory leak in a kernel driver could crash the entire operating system. 

To solve this, Linux introduces **FUSE (Filesystem in Userspace)**. FUSE is a bridge that allows developers to write filesystem drivers as standard, safe, user-space applications. 

When you use SSHFS:
1.  An application runs a read request on a mounted folder (e.g., `cat /mnt/ssh/file.txt`).
2.  The kernel's Virtual Filesystem (VFS) receives this request and routes it to the FUSE kernel module.
3.  The FUSE kernel module passes the request out of the kernel space and into the user-space **`sshfs`** daemon running on your system.
4.  The `sshfs` daemon translates this filesystem read into a standard SFTP network request, encrypts it, and sends it over a standard SSH connection to the remote server.
5.  The remote server's SSH daemon reads the file from its local disk and sends the data back over the encrypted network tunnel.
6.  The local `sshfs` daemon receives the data, decrypts it, and passes it back down through the FUSE kernel module to the VFS, which finally delivers it to your application.

This round-trip context switching between kernel space and user space introduces CPU overhead and latency. But for ad-hoc, secure access, it is incredibly powerful because it requires no special server-side software other than standard SSH.

### NFS: The Kernel-Space Pipeline
NFS operates on a completely different philosophy. It is built directly into the Linux kernel itself. 

When you mount an NFS share, the client's kernel talks directly to the server's kernel using a specialized RPC (Remote Procedure Call) protocol. There is no context switching between kernel space and user space, no user-space daemon translating blocks, and no heavy SSH encryption layer. 

This deep kernel integration makes NFS incredibly fast. It is designed for **ReadWriteMany (RWX)** scenarios, allowing dozens of independent application servers to mount the exact same storage directory simultaneously, reading and writing files with near-local performance.

---

## The Administrator's Toolkit

To construct these remote storage bridges, we use specialized mounting commands and export configurations.

### The SSHFS FUSE Mount
Because FUSE is designed to protect users, it enforces strict isolation. By default, if the user `ubuntu` mounts a directory using SSHFS, even the system's `root` user is blocked from looking inside that directory. 

To override this security boundary and allow system services or other users to access the remote data, we must explicitly pass specialized option flags:
- `-o allow_other`: Tells FUSE to drop its isolation shield, permitting other users and system daemons to read and write to the mounted path.
- `-o default_permissions`: Tells the kernel to enforce standard Unix user/group ownership permissions inside the mount, ensuring safety.

### The NFS Server Configuration (`/etc/exports`)
On an NFS server, we declare which directories we want to share with the network inside `/etc/exports`. A typical entry looks like this:

```text
/data-export  10.10.40.0/24(ro,sync,no_subtree_check)
```

Let's dissect these parameters:
- `10.10.40.0/24`: The whitelisted network range. Only machines with IP addresses in this subnet can access the share.
- `ro` / `rw`: Controls permissions. `ro` shares the files as read-only; `rw` grants read and write permissions.
- `sync`: Forces the NFS server to commit every write to the physical disk before sending a confirmation back to the client. This prevents data loss in a power failure, although it introduces minor latency compared to `async`.
- `no_subtree_check`: Disables verification that a requested file resides within the exact exported subdirectory. If a file is moved or renamed on the server while a client has it open, subtree checking can cause errors. Disabling it improves both speed and reliability.

---

## Scenario: Connecting Two Remote Servers

Let's walk through a real-world scenario. You have two servers running on a private network: a main controller terminal named `terminal` (IP: `10.10.40.10`) and an application server named `app-srv1` (IP: `10.10.40.20`). 

Your tasks are:
1.  Use **SSHFS** to mount a data folder `/data-export` residing on `app-srv1` onto `terminal` at `/app-srv1/data-export`.
2.  Use **NFS** to export a shared backup folder `/nfs/share` from `terminal` to the network, and mount it on `app-srv1` as a read-only backup vault.

---

### Step 1: Mounting with SSHFS (Client `terminal` $\rightarrow$ Source `app-srv1`)

First, log into the `terminal` server. We create our local gateway directory where the remote files will appear:

```bash
sudo mkdir -p /app-srv1/data-export
```

Now, we perform our SSHFS mount, pulling the files across the network securely. We pass our critical FUSE isolation-bypass options:

```bash
sudo sshfs -o allow_other,default_permissions root@app-srv1:/data-export /app-srv1/data-export
```

Because SSHFS rides on standard SSH, you will be prompted to trust the remote host's key fingerprint and enter the remote SSH credentials. Once authenticated, run `df -h` to verify:

```bash
df -h -t fuse.sshfs
```

The system confirms that the FUSE bridge is established:

```text
Filesystem             Size  Used Avail Use% Mounted on
root@app-srv1:/data-export  20G   2.4G   17G  13% /app-srv1/data-export
```

You can now use standard tools like `ls` or `grep` on `/app-srv1/data-export`. The files appear local, but they are being retrieved dynamically from `app-srv1`.

---

### Step 2: Configuring the NFS Server (on `terminal`)

Now, we want to share `/nfs/share` from `terminal` out to the application server `app-srv1`. Open `/etc/exports` in your editor on `terminal`:

```bash
sudo nano /etc/exports
```

Add our export line, whitelisting our app subnet and locking down permissions to read-only (`ro`):

```text
/nfs/share  10.10.40.0/24(ro,sync,no_subtree_check)
```

Save and close the file. 

If we restart the NFS service, we will disrupt active client connections. Instead, we perform a hot-reload of the configuration using the `exportfs` utility:

```bash
sudo exportfs -arv
```

Let's dissect these flags:
- `-a`: Targets all exports defined in `/etc/exports`.
- `-r`: Re-exports directories, synchronizing the server's active memory map with our configuration file.
- `-v`: Verbose mode, displaying active export parameters.

The terminal outputs the successfully reloaded share:

```text
exporting 10.10.40.0/24:/nfs/share
```

---

### Step 3: Mounting the NFS Export (on Client `app-srv1`)

Now, log into the application client `app-srv1`. Before mounting, we want to verify that we can see the available exports from our terminal server. We query the remote server's RPC daemon using `showmount`:

```bash
showmount -e 10.10.40.10
```

The server responds with its active export map:

```text
Export list for 10.10.40.10:
/nfs/share 10.10.40.0/24
```

Our client is cleared to access the share. We create our local mount point directory:

```bash
sudo mkdir -p /nfs/terminal/share
```

Now we execute the mount, specifying that we want to use the `nfs` driver:

```bash
sudo mount -t nfs 10.10.40.10:/nfs/share /nfs/terminal/share
```

Let's verify that the mount is active and running over the NFS protocol:

```bash
df -h -t nfs4
```

The system shows the successful remote mount:

```text
Filesystem                 Size  Used Avail Use% Mounted on
10.10.40.10:/nfs/share      40G  1.2G   37G   4% /nfs/terminal/share
```

Let's test the read-only constraint. Try to create a file inside the share:

```bash
touch /nfs/terminal/share/test_write.txt
```

The kernel's NFS client driver blocks the write immediately, returning the correct restriction:

```text
touch: cannot touch '/nfs/terminal/share/test_write.txt': Read-only file system
```

---

## Common Pitfalls

- **The Stale NFS Hang**: If the NFS server (`terminal`) suddenly goes offline or suffers a power cut, any terminal command on the client (`app-srv1`) that scans filesystems—such as running `df -h` or `ls`—will **freeze completely**. The shell hangs indefinitely, waiting for a response from the dead server. 
  
  To prevent this system-wide locking, always configure your NFS mounts inside `/etc/fstab` with the **`soft`** and **`intr`** flags. 
  
  - **`soft`** tells the client kernel to stop trying to retransmit a request after a few seconds and return an input/output error instead of hanging.
  - **`intr`** allows you to send a signal (like `SIGINT` via `Ctrl+C`) to abort the hung command.
  
- **Subnet Locking**: NFS relies on strict IP source checking. If your client server is assigned an IP of `10.10.50.20` due to a DHCP change, but your `/etc/exports` only whitelisted `10.10.40.0/24`, the mount command will fail with a generic "Permission Denied" error. Always double-check your CIDR subnets when network boundaries shift.

---

## Self-Check and Verification

Test your network storage knowledge with these scenarios:
1.  **FUSE Boundaries**: You mounted an SSHFS folder as the system user `ubuntu`, but when you run `sudo backup-script` (which runs as root), the script cannot read the directory. What is the solution? *(Answer: FUSE isolates mount points to the mounting user by default. You must mount the SSHFS directory with the `-o allow_other` option to let other users—including root—read the contents).*
2.  **Hot Reloads**: You added a new directory share to `/etc/exports` on an active production NFS server. Why should you avoid restarting the `nfs-server` systemd service? *(Answer: Restarting the systemd service tears down active sockets, terminating connections and causing I/O errors on existing clients. Running `sudo exportfs -arv` reloads the exports cleanly in memory without disrupting active network connections).*
3.  **Active Mount Hanging**: An NFS server crashes, and your client terminal session is completely frozen. How do you recover? *(Answer: If the share was mounted with `intr`, you can press `Ctrl+C` to abort the active shell command. To force-disconnect the dead mount, run `sudo umount -f -l /nfs/terminal/share` to perform a lazy, forced unmount).*
