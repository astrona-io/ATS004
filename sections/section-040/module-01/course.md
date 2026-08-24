# Temporary Safety Valves: Swap Files

When a Linux server runs out of physical RAM, it faces a crisis. Applications are demanding memory that does not exist. The kernel has a built-in mechanism for this exact scenario: the Out-Of-Memory (OOM) Killer. The OOM Killer acts as a ruthless bouncer. It analyzes the running processes, finds the one consuming the most memory, and violently terminates it to free up resources. This is necessary to keep the operating system alive, but it usually means the database you were trying to run just crashed.

Swap space prevents the paper shredder. Think of RAM as your active work desk. It is fast, but limited in size. Swap space is the cabinet drawer beneath the desk. When the desk is full, you pull the least-used folders off the desk and shove them into the drawer. It takes longer to retrieve them later, but nothing gets destroyed.

Swap files are the fastest way to add emergency capacity to a running system without repartitioning disks.

## Allocating and Securing Swap Space

A swap file is just a massive, empty file sitting on your existing filesystem. To create one, you must allocate the space.

While you can use `dd` to write zeroes to a file block by block, `fallocate` is significantly faster. It tells the filesystem to instantly reserve the blocks without writing the actual zeroes.

```bash
fallocate -l 2G /swapfile
```

This reserves exactly 2 Gigabytes of space for `/swapfile`.

Before you format this file, you must secure it. When the kernel moves data from RAM into swap, it writes raw memory pages directly to the disk. This includes passwords, encryption keys, and active database transactions. If a regular user can read the swap file, they can extract every secret on the server.

You must lock the permissions down so only the root user can read or write the file.

```bash
chmod 600 /swapfile
```

If you attempt to format or activate a swap file with insecure permissions, modern kernels will flag a warning and may refuse to mount it entirely.

## Formatting and Activation

Once the file is allocated and secured, you format it using `mkswap`. This command writes the swap header, turning the raw file into a structure the kernel's memory manager understands.

```bash
mkswap /swapfile
```

To instruct the kernel to begin using the file as active virtual memory, use the `swapon` command.

```bash
swapon /swapfile
```

The system is now protected. If RAM fills up, the kernel will page idle memory blocks into this 2GB file instead of invoking the OOM Killer.

You verify the active swap spaces using `swapon --show` or by reading `/proc/swaps`.

```bash
swapon --show
```

If you need to reclaim the disk space later, you must turn the swap file off first. The `swapoff` command forces the kernel to move all data currently in the swap file back into physical RAM. If there is not enough RAM available to hold the data, the command will fail.

```bash
swapoff /swapfile
```

## Self-Check and Verification

To prove you can provision emergency swap memory:

1. Use `free -m` to check current memory and swap usage.
2. Allocate a 1GB file named `/tmp_swap` using `fallocate`.
3. Set strict read/write permissions for root only using `chmod`.
4. Format the file using `mkswap`.
5. Activate the swap space with `swapon`.
6. Run `swapon --show` to verify the kernel registers the new swap file and note its size.
7. Deactivate the file using `swapoff` and verify it is removed from the active list.
