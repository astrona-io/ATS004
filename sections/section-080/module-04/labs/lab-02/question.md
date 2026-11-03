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
