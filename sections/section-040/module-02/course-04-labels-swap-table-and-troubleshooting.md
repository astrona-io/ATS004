# Labels, the Swap Table and Fixing a Swap That Will Not Start

When swap does not come back after a launch, the cause is nearly always a small mismatch: a wrong UUID, a missing header or a stale line. This part shows the tools that read the swap table, how to give a swap area a painted name, and how to find a bad fstab line.

## Reading the swap table

The kernel keeps a live table of its swap areas in `/proc/swaps`. It is one of the core's status screens: nothing is stored, and every read is a fresh reading. `swapon --show` prints the same facts, and you can pick the columns. `blkid` reads the header on the device itself, so it works even when the swap is switched off.

The commands below need `/dev/vdb1` active as swap with priority 10 and `/swapfile` with priority 5.

<!-- astrona:playground:renew -->

### See it in your playground

Read the table in three ways:

```sh
cat /proc/swaps
swapon --show=NAME,SIZE,USED,PRIO
sudo blkid /dev/vdb1
```

`/proc/swaps` has the columns `Filename`, `Type`, `Size`, `Used` and `Priority`. The `swapon --show=...` line prints only the four columns you asked for. `blkid` shows the partition's UUID and `TYPE="swap"`. If `blkid` shows no `TYPE`, the device has no swap header, and `swapon` will refuse it.

## Giving a swap area a label

A UUID is the hold's serial number. A label is a painted name that is easier to read. `swaplabel` changes the label or the UUID of a swap area without erasing it. This is different from running `mkswap` again, which writes a new header and a new UUID. The area must be switched off first.

### See it in your playground

Switch off the partition, label it, switch it on again with its priority, and read the label back:

```sh
sudo swapoff /dev/vdb1
sudo swaplabel -L OVERFLOW /dev/vdb1
sudo swapon -p 10 /dev/vdb1
sudo blkid /dev/vdb1
```

`blkid` now shows `LABEL="OVERFLOW"` next to the same UUID as before. The fstab line that uses `UUID=` still works. An fstab line could also name the device as `LABEL=OVERFLOW`.

## Finding a bad swap line

A swap line that points at a device that does not exist fails when the system tries to start it. Start the swap by hand with `swapon -a` and it tells you which line is bad, while the ship is still flying. Test with a line that has a made-up UUID, then remove it.

### See it in your playground

Append a line with a UUID that matches no device, and apply the logbook:

```sh
echo 'UUID=00000000-0000-0000-0000-000000000000  none  swap  sw  0  0' | sudo tee -a /etc/fstab
sudo swapon -a
```

`swapon -a` prints an error that it cannot find the device for that UUID. The other areas stay active. Remove the bad line again, and check the end of the file:

```sh
sudo sed -i '$d' /etc/fstab
tail -n 3 /etc/fstab
```

The bad line must be gone, and your two real swap lines must remain. If a real line was removed, restore with `sudo cp /etc/fstab.orig /etc/fstab` and write the lines again.

## Common pitfalls

> [!WARNING]
> - **Running `mkswap` again to add a label.** It makes a new UUID, and the UUID in `/etc/fstab` no longer matches. Use `swaplabel`.
> - **Running `swaplabel` on an active area.** Switch the area off first.
> - **Trusting `blkid` output from a device with no `TYPE`.** No `TYPE` means no swap header. Run `mkswap` before `swapon`.
> - **Using `sed -i '$d'` without looking.** It deletes the last line of the file, whatever it is. Look with `tail` first.
