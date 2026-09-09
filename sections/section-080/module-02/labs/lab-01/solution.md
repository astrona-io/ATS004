# Solution Guide: User and Group Disk Quotas

This guide shows you how to turn on ext4 quotas and set per-user and per-group limits.

---

## Step 1: Build Accounting Files and Enable Enforcement

`/quota` is already mounted with `usrquota,grpquota` — confirm it, then build the accounting files and switch enforcement on:

```bash
findmnt -no OPTIONS /quota
sudo quotacheck -cugv /quota
sudo quotaon -v /quota
sudo quotaon -p /quota
```

`quotacheck -cugv` scans the filesystem and creates `aquota.user` / `aquota.group` at its root. `quotaon` then activates limit checking for both user and group quotas.

---

## Step 2: Set alice's Block Quota

```bash
sudo setquota -u alice 40M 50M 0 0 /quota
```

40 MiB soft, 50 MiB hard, no inode limit (`0 0`).

---

## Step 3: Set bob's Block Quota

```bash
sudo setquota -u bob 20M 30M 0 0 /quota
```

---

## Step 4: Set team's Group Block Quota

```bash
sudo setquota -g team 100M 120M 0 0 /quota
```

---

## Step 5: Confirm the Limits

```bash
sudo repquota -s /quota
sudo repquota -sg /quota
```

`repquota -s` reports every user's block/inode usage against their limits in human-readable units; `-g` switches the report to groups.
