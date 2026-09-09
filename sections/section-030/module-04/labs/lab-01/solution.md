# Solution Guide: RAID5 Failure Recovery

This guide walks through failing, removing, and replacing a RAID5 member disk.

---

## Step 1: Load the Device Names

```bash
source /etc/lab034-raid
echo "$member1 $member2 $member3 $spare"
```

---

## Step 2: Fail and Remove the Bad Disk

Mark `$member2` faulty, then detach it from the array:
```bash
sudo mdadm --manage /dev/md0 --fail "$member2"
cat /proc/mdstat
sudo mdadm --manage /dev/md0 --remove "$member2"
```

The array is now **degraded** — still serving data (RAID5 tolerates one loss), but with no remaining redundancy.

---

## Step 3: Add the Spare and Rebuild

```bash
sudo mdadm --manage /dev/md0 --add "$spare"
cat /proc/mdstat
```

`md` immediately starts a rebuild, reading the surviving disks and reconstructing what belonged on the new one.

---

## Step 4: Wait for the Rebuild and Verify

```bash
sudo mdadm --wait /dev/md0
sudo mdadm --detail /dev/md0 | grep -E 'State|Active Devices|Failed Devices'
cat /proc/mdstat
cat /mnt/raid/data.txt
```

Expect `State : clean`, `Active Devices : 3`, `Failed Devices : 0`, and `/proc/mdstat` showing `[3/3] [UUU]` with no `(F)` marker. `/mnt/raid/data.txt` still reads correctly — the array never stopped serving data through the whole process.
