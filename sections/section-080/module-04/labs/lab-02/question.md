# Question

Solve this question on: `terminal`

Astronaut, a new service called `acme` was unpacked into the staging directory `/srv/staging`. It holds four files. Put each one where the Filesystem Hierarchy Standard says it belongs, then link them.

| File in `/srv/staging` | What it is | Where it must go |
| --- | --- | --- |
| `acme.conf` | the settings file | `/etc/acme/acme.conf` |
| `acme-report` | an executable program added locally by the administrator | `/usr/local/bin/acme-report` |
| `acme.log` | the log file | `/var/log/acme/acme.log` |
| `inventory.db` | data the service changes while it runs | `/var/lib/acme/inventory.db` |

1. Create the missing directories and **move** the four files, so that `/srv/staging` is left empty. Keep `acme-report` executable.
2. Create a **hard link** named `/var/lib/acme/acme.conf.keep` to `/etc/acme/acme.conf`. The two names must share one inode.
3. Create a **symbolic link** named `/usr/local/bin/acme` that points to `/usr/local/bin/acme-report`.
4. Create a **symbolic link** named `/var/lib/acme/current.log` that points to `/var/log/acme/acme.log`.
5. Check the links with `ls -li`, `readlink -f` and `stat -c '%i %h %n'`.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-04](../../course.md).

The grader checks:

- Confirms the four files are in their FHS places, the hard link shares an inode, and both symbolic links resolve.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
