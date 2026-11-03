# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about cargo allowances on an XFS hold, including an allowance for a whole mission: the project quota.

**From [XFS Quotas & User Limits](./course-01-xfs-quotas-and-user-limits.md):**

- XFS quotas are a mount option (`uquota`, `gquota`, `pquota`). There is no `quotacheck` and no `quotaon` in the normal case.
- XFS reads its quota options at mount time, so `mount -o remount` does not turn them on.
- `xfs_quota -x -c 'limit bsoft=40m bhard=50m alice' <filesystem>` sets a user limit. `-x` is needed to change anything.

**From [Defining & Enforcing a Project Quota](./course-02-project-quotas.md):**

- A project needs a line in `/etc/projects` (number to path) and in `/etc/projid` (name to number).
- `xfs_quota -x -c 'project -s <name>'` stamps the existing files once and sets inheritance for new ones.
- `limit -p bhard=100m <name>` caps the whole tree, whoever writes into it.

**From [Group Limits, Grace Timers & Switching Quotas Off](./course-03-group-quotas-timers-and-switching-off.md):**

- `limit -g`, `quota -u` and `timer` cover groups, single-account reports and grace times.
- `off` stops a quota type until the next mount. Set limits to `0` to lift them instead.

## Your missions

You proved the skills in graded missions, right after the parts that taught them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [XFS Project Quota Lab](./labs/lab-01/README.md) | Defining & Enforcing a Project Quota | set a user limit, define the `webdata` project and cap it at 100m |
| [Copy User Quotas and Set XFS Group Limits Lab](./labs/lab-02/README.md) | Group Limits, Grace Timers & Switching Quotas Off | copy user limits with `edquota -p`, and set XFS group limits and the block timer |

If you skipped one, go back to it now. They are short, and the exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Why does XFS need no <code>quotacheck</code>?</summary>

XFS keeps quota accounting in its own metadata from the day it was created, and updates it on every allocation. The mount option only starts enforcement.
</details>

<details>
<summary>2. You mounted an XFS filesystem without <code>uquota</code>. Does <code>mount -o remount,uquota</code> fix it?</summary>

No. XFS reads quota options at mount time. Unmount the filesystem and mount it again with the option.
</details>

<details>
<summary>3. Which two files define a project?</summary>

`/etc/projects` holds `<id>:<path>`. `/etc/projid` holds `<name>:<id>`.
</details>

<details>
<summary>4. What does <code>xfs_quota -x -c 'project -s webdata' /srv/xfs</code> do?</summary>

It stamps project number 42 onto the existing files under the project directory, and sets the inheritance flag so new files get the number when they are created.
</details>

<details>
<summary>5. Alice and bob both write into a project directory with a 100m limit. Whose limit applies?</summary>

The project's. The kernel checks the project number on the file, not the owner, so their writes count together.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-080-module-03-playground
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-004-lab-084
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the mission from this module. You can start the playground again at any time with the `astrona run` command from the end of the mission; it always starts clean, so nothing you broke carries over.

<!-- astrona:playground:destroy -->
