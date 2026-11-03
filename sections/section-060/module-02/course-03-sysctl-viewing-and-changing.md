# sysctl: Viewing and Changing Parameters

The `/sys` files were mostly readouts with the odd dial. The files under `/proc/sys/` are the dials of the core itself. Each one is a live, writable kernel parameter, and `sysctl` is the usual way to read and change them.

## Viewing and changing kernel parameters

A concrete case first. `net.ipv4.ip_forward` decides whether the kernel passes network packets from one interface to another, as a router would. It is `0` by default. This section shows how the dotted name maps to a file and how to change the value.

### Names map to paths

`sysctl` turns each `/proc/sys/` path into a dotted name, so `/proc/sys/net/ipv4/ip_forward` becomes `net.ipv4.ip_forward`. That is the whole relationship. `sysctl <name>` and `cat /proc/sys/<path>` read the same value through the same kernel handler. `sysctl -w` and a direct write trigger the same write handler. `sysctl` is a name-translation convenience, not a separate system.

### Why `sudo echo 1 > file` fails

The shell opens the redirect as your normal user before `sudo` runs, so the write is refused before `sudo` is involved. Two forms work. `sudo sysctl -w name=value` runs the whole write as root. `echo 1 | sudo tee <file>` lets `tee`, which runs under `sudo`, do the writing.

<!-- astrona:playground:renew -->

### See it in your playground

Read the value, change it, check it through the raw file, and put it back.

```sh
sysctl net.ipv4.ip_forward
sudo sysctl -w net.ipv4.ip_forward=1
cat /proc/sys/net/ipv4/ip_forward
sudo sysctl -w net.ipv4.ip_forward=0
```

Expect something like this:

```text
net.ipv4.ip_forward = 0
net.ipv4.ip_forward = 1
1
net.ipv4.ip_forward = 0
```

`sysctl -w` set the value, and `cat` on the raw `/proc/sys` file shows the same `1`. It is not a synced copy. It is the same parameter read through two names. On this single-interface ship, `ip_forward` has no visible effect. On a real router it changes packet handling the moment it is set.

## Finding and filtering parameters

The kernel has hundreds of dials. This section shows how to find the one you need.

### List and search

`sysctl -a` prints every parameter with its value. Pipe it through `grep` to search by name. `sysctl -n <name>` prints only the value, which suits scripts.

### See it in your playground

Search the list for the parameters with `forward` in the name, then read one value alone.

```sh
sysctl -a 2>/dev/null | grep forward
sysctl -n net.ipv4.ip_forward
```

The first command prints one line per matching parameter in the form `name = value`. The second prints only the number. The `2>/dev/null` hides warnings about parameters that the login user may not read.

## Common pitfalls

> [!WARNING]
> - **`sudo echo 1 > /proc/sys/...`.** The shell performs the `>` as your user before `sudo` starts, so it fails with "Permission denied". Use `sudo sysctl -w name=value` or `echo 1 | sudo tee /proc/sys/...`.
> - **Editing `/proc/sys` and calling it permanent.** A runtime write is lost at reboot. Persistence needs a file in `/etc/sysctl.d/`.
> - **Thinking `sysctl` and `/proc/sys` hold two values.** The dotted name `net.ipv4.ip_forward` and the path `/proc/sys/net/ipv4/ip_forward` are the same parameter. Changing one changes the other.
