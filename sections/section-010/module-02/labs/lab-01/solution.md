# Solution Walkthrough

You write two things on the new disk with `parted`: a GPT label (the deck plan), then one partition from 1 MiB to 1 GiB (the first room). The last step checks the same two facts the grader checks.

---

## Step 1: Find the raw disk

List all block devices and look for the new 2 GB disk:

```bash
lsblk
```

Look for a 2G disk with no child partitions and no mount point, for example `/dev/vdb`. The system disk, `/dev/vda`, is the one with the operating system on it. Do not touch it.

Confirm the device through its serial number. The link points to the real device name:

```bash
ls -l /dev/disk/by-id/virtio-lab011-raw
```

The end of the line, after `->`, names the device (for example `../../vdb`). Use that name in every step below.

---

## Step 2: Write the GPT label

Use `parted` to write a GPT partition table to the disk:

```bash
sudo parted /dev/vdb mklabel gpt
```

Replace `/dev/vdb` with the device you found in Step 1 if it is different. `parted` writes the label at once; there is no separate save step.

---

## Step 3: Create the partition

Create one partition that starts at 1 MiB (sector 2048) and ends at 1 GiB:

```bash
sudo parted /dev/vdb mkpart primary ext4 1MiB 1GiB
```

On a GPT disk, `primary` is stored as the partition's name, and `ext4` is only a type hint. Neither one formats the partition, which is what the task wants: leave it unformatted and unmounted.

---

## Step 4: Check the layout

Print the table:

```bash
sudo parted /dev/vdb print
```

Look for the line `Partition Table: gpt` and a single partition, number 1, of about 1 GB that starts at `1049kB` (1 MiB).

Now check the start sector, which is what the grader reads:

```bash
sudo fdisk -l /dev/vdb
```

In the partition list at the bottom, the `/dev/vdb1` line must show `2048` in the `Start` column. You can also confirm the alignment with `sudo parted /dev/vdb align-check optimal 1`, which should answer `1 aligned`.

When both checks look right, send the mission for grading:

```sh
astrona submit -c sections/section-010/module-02/labs/lab-01
```
