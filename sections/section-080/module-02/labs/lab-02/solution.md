# Solution Walkthrough

---

## Step 1: Hit the hard limit

```bash
sudo -u carol dd if=/dev/zero of=/quota2/carol/bigfile bs=1M count=30
```

Expect:

```text
dd: error writing '/quota2/carol/bigfile': Disk quota exceeded
24+0 records in
23+0 records out
```

`dd` writes up to the 25M ceiling and stops — nothing beyond it lands on
disk.

```bash
sudo -u carol du -sh /quota2/carol
```

Expect the directory's usage to sit at or just under 25M, never over.

---

## Step 2: Observe the grace period

```bash
sudo setquota -t 120 120 /quota2
sudo -u carol dd if=/dev/zero of=/quota2/carol/overfile bs=1M count=22
```

`overfile` alone is under the hard limit but pushes carol's *total* usage
in `/quota2/carol` over her 20M soft limit — you may need to remove
`bigfile` first (`sudo -u carol rm /quota2/carol/bigfile`) so there is
room for `overfile` to land without immediately hitting the hard ceiling
again.

```bash
sudo repquota -s /quota2 | sudo tee /root/grace-evidence.txt
```

Expect carol's line to carry a `*` next to her usage and a grace value
counting down from 2 minutes — she is over soft, still under hard, so the
write succeeded but the clock has started.
