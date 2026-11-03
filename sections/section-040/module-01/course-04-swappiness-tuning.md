# Tuning Swap Behaviour with swappiness

The kernel has one main dial for how eagerly it moves memory into swap. It is called `vm.swappiness`. This part shows how to read it, turn it, and keep the new setting after a reboot.

## What the dial does

When memory runs low, the kernel can free RAM in two ways. It can drop page cache, which is a copy of file data that it can read from disk again. Or it can write anonymous memory (the memory a process owns, with no file behind it) out to swap. `vm.swappiness` sets how much the kernel prefers swap over dropping cache. The range is 0 to 200 on modern kernels. A higher value swaps sooner. A low value, such as 10, keeps process memory in RAM longer and drops cache first. The default on Ubuntu 24.04 is 60.

The dial lives in the core's control panel. Each value there is a file under `/proc/sys/`, and `sysctl` is the tool that reads and sets those values.

<!-- astrona:playground:renew -->

### See it in your playground

Read the dial in two ways. They show the same number:

```sh
sysctl vm.swappiness
cat /proc/sys/vm/swappiness
```

On a fresh Ubuntu 24.04 ship both show the default of 60. Now turn the dial down for the running ship only:

```sh
sudo sysctl vm.swappiness=10
sysctl vm.swappiness
```

The second command shows 10. The change took effect at once. The kernel holds it in memory only, so a reboot would bring back 60.

## Keeping the value after a reboot

To keep a `sysctl` value, write it into the logbook page that the system reads at every launch. That page is a file in `/etc/sysctl.d/`. Files there are read in name order, and a later name wins.

Save this as `/etc/sysctl.d/99-swappiness.conf` (a file under `/etc` is saved with `sudo`, for example `sudo nano /etc/sysctl.d/99-swappiness.conf`):

```text
vm.swappiness = 10
```

Apply it:

```sh
sudo sysctl --system
```

`sysctl --system` reads every file in the `sysctl` directories, in order, and prints the name of each file it loads. Then check the result:

```sh
sysctl vm.swappiness
```

The value is 10, and it now comes back at every launch because the file stays.

## Common pitfalls

> [!WARNING]
> - **Setting the value only with `sysctl vm.swappiness=10`.** It is lost at the next reboot. Write the line to a file in `/etc/sysctl.d/`.
> - **Thinking `vm.swappiness=0` turns swap off.** It only makes the kernel avoid swapping until it has no better choice. To turn swap off, use `swapoff`.
> - **Putting spaces wrong or a typo in the key.** The file accepts `key = value`, but a misspelled key is only reported when you run `sudo sysctl --system`. Always run it and read the output.
> - **Expecting swappiness to add swap.** It changes how the kernel uses swap that exists. With no swap active, it has no effect on anonymous memory.
