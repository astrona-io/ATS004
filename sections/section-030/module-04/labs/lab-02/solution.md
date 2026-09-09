# Solution Walkthrough

---

## Step 1: Source the device names

```bash
. /etc/lab036-raid
```

---

## Step 2: Add the spare and grow the array

```bash
sudo mdadm --manage /dev/md0 --add "$spare"
sudo mdadm --grow /dev/md0 --raid-devices=4
cat /proc/mdstat
```

Expect the spare to join as a new device and a `reshape` progress line to
appear — the array rewrites its stripe layout across all four disks.

---

## Step 3: Wait for the reshape

```bash
sudo mdadm --wait /dev/md0
sudo mdadm --detail /dev/md0 | grep -E 'State|Raid Devices'
```

Expect `Raid Devices : 4` and `State : clean` once the reshape finishes.

---

## Step 4: Grow the filesystem

```bash
sudo resize2fs /dev/md0
df -h /mnt/raid-grow
```

The array is bigger, but the filesystem doesn't notice until `resize2fs`
rewrites its own size fields — the same rule as growing an LVM volume.

---

## Step 5: Verify the data survived

```bash
cat /mnt/raid-grow/data.txt
```

---

## Step 6: Set up failure notification

```bash
echo "MAILADDR root@localhost" | sudo tee -a /etc/mdadm/mdadm.conf
sudo mdadm --monitor --scan --oneshot --test
```

`--oneshot --test` fires one `TestMessage` event per array through
whatever notification path is configured — confirming the monitoring path
itself works, independent of whether real mail delivery is set up.
