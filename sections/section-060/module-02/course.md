# The Hardware Tree & Runtime Tuning: /sys & sysctl

While `/proc` is primarily focused on software and processes, the `/sys` directory focuses on hardware. It is another pseudo-filesystem, created by the kernel, designed to expose the hierarchical tree of devices attached to your machine.

If `/proc` is the dashboard gauges, `/sys` and `/proc/sys` are the dashboard dials. They don't just let you see the state of the engine; they let you change the tuning while the car is driving down the highway.

## Navigating the Hardware Tree (/sys)

The `/sys` filesystem organizes hardware by buses (like PCI or USB) and classes (like block devices or network interfaces).

If you want to know the exact sector size of your primary hard drive, you don't need a specialized disk utility. You navigate to the block class and read the queue configuration.

```bash
cat /sys/class/block/sda/queue/hw_sector_size
```

If you plug in a new USB drive, the kernel dynamically creates a new tree in `/sys` representing that device, exposing everything from its vendor ID to its power management states.

## The Absolute Truth of Mounts

When dealing with filesystems, the standard `mount` command reads from `/etc/mtab`. Sometimes, this file gets out of sync with reality. If you want the absolute, unarguable truth of what filesystems the kernel currently has mounted, you read `/proc/mounts`.

```bash
cat /proc/mounts
```

This is not a text file updated by user-space programs; it is a direct callback to the kernel's internal mount table. If a mount exists here, it is active.

## Runtime Kernel Tuning (sysctl)

The most dangerous and powerful area of the virtual filesystem is `/proc/sys/`. This directory contains active kernel parameters that you can modify in real-time.

For example, Linux by default refuses to act as a router. It will not forward network packets arriving on one interface out through another. You can change this behavior instantly without a reboot by writing a `1` into the IP forwarding intercept file.

```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
```

The moment you hit enter, the kernel changes its network routing behavior.

### Using sysctl

While you can use `echo` to write to these files directly, the standard tool for managing them is `sysctl`. It translates the directory paths into dot-notation for easier reading and modification.

To view the same IP forwarding parameter:

```bash
sysctl net.ipv4.ip_forward
```

To modify it:

```bash
sysctl -w net.ipv4.ip_forward=1
```

Changes made via `echo` or `sysctl -w` are temporary. They evaporate the moment the server reboots. To make kernel tuning permanent, you must write the dot-notation parameters into `/etc/sysctl.conf` or a custom file inside `/etc/sysctl.d/`.

```text
net.ipv4.ip_forward = 1
```

You then force the system to read the configuration files and apply them to the live `/proc/sys/` tree.

```bash
sysctl -p
```

## Self-Check and Verification

To prove you can tune the active kernel:

1. Read the raw kernel mount table using `cat /proc/mounts` and identify the filesystem type of your root partition.
2. Query your current IPv4 forwarding state using `sysctl net.ipv4.ip_forward`.
3. Enable IP forwarding temporarily by writing directly to the virtual file: `echo 1 > /proc/sys/net/ipv4/ip_forward`.
4. Verify the change took effect using `sysctl`.
5. Persist the change by appending `net.ipv4.ip_forward = 1` to `/etc/sysctl.conf`.
6. Reload the configuration using `sysctl -p` to ensure the syntax is correct.
