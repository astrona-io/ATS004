# Solution Walkthrough

Three moves: copy the limits on ext4, set the group limits on XFS, and set the XFS timer. After each step you can run `astrona submit -c sections/section-080/module-03/labs/lab-02` to see what the grader still misses.

---

## Step 1: Copy alice's limits to bob and carol

First look at the model user and at the two users who still have nothing:

```sh
sudo repquota -s /quota-ext
```

`alice` shows `40M` and `50M`. `bob` and `carol` show `0` for both, which means no limit. Now copy the limits:

```sh
sudo edquota -p alice bob carol
sudo repquota -s /quota-ext
```

`edquota -p alice` uses `alice` as the prototype. It copies her limits to each user named after it. The report now shows `40M` and `50M` for all three.

---

## Step 2: Set the group block limits on XFS

XFS quotas are set with `xfs_quota`. The `-x` switch turns on expert mode, which is needed to change anything:

```sh
sudo xfs_quota -x -c 'limit -g bsoft=50m bhard=80m engineers' /srv/xfs-teams
sudo xfs_quota -x -c 'report -g -b -h' /srv/xfs-teams
```

`limit -g` sets a limit for a group. `bsoft` is the warning line and `bhard` is the wall, both in blocks. The report shows `50M` and `80M` on the `engineers` line.

---

## Step 3: Set the group grace timer

The grace time says how long a group may stay over the warning line before it is stopped. The default is 7 days. Set it to 3 days for block limits:

```sh
sudo xfs_quota -x -c 'timer -g -b 3days' /srv/xfs-teams
sudo xfs_quota -x -c 'state -g' /srv/xfs-teams
```

The state output has a line like `Blocks grace time: [3 days]`. The timer is one setting for the whole filesystem and applies to every group on it. Run `astrona submit` for the final grade.
