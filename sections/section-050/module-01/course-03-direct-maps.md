# Direct Maps and a Fixed Mount Point

An indirect map manages a whole corridor of hatches under one parent directory. Sometimes you need only one hatch at a fixed place, such as `/mnt/archive`. For that the master map has a second form, the direct map.

## Direct versus indirect

In a **direct map**, the master line uses `/-` in place of a managed directory, and the map file lists full, absolute paths as keys. In an **indirect map**, the master line names a parent directory, and the keys are short names under it.

| Form | Master line | Key in the map file |
| --- | --- | --- |
| Indirect | `/mnt/auto  /etc/auto.demo  --timeout=15` | `data` (a name under `/mnt/auto`) |
| Direct | `/-  /etc/auto.direct  --timeout=60` | `/mnt/archive` (a full path) |

Use a direct map for a few fixed mount points scattered around the tree. Use an indirect map for many siblings under one parent. If a direct entry and an indirect entry could both claim a path, the direct one wins, because it names the exact path.

The timeout belongs to the master line, so every entry in that map shares it. The key is the whole path, so the map file's first field is the mount point itself.

## Writing a direct map

The commands below need the `autofs` service running and `/srv/localdata` present. Start from the original master map, so earlier lines do not get in the way:

```sh
sudo cp /etc/auto.master.orig /etc/auto.master
```

Save this as `/etc/auto.direct` (a file under `/etc` is saved with `sudo`, for example `sudo nano /etc/auto.direct`):

```text
/mnt/archive  -fstype=bind  :/srv/localdata
```

<!-- astrona:playground:renew -->

### See it in your playground

Add the master line, reload, and look at the trigger:

```sh
echo '/-  /etc/auto.direct  --timeout=60' | sudo tee -a /etc/auto.master
sudo systemctl reload autofs
mount | grep archive
```

`mount` shows `/mnt/archive` with type `autofs`. The trigger sits exactly on the path you named, and no parent directory is managed. Now knock on the hatch:

```sh
ls /mnt/archive
mount | grep archive
```

The `ls` lists `hello.txt` and `notes.txt`. `mount` now shows a second line: a bind mount of `/srv/localdata` on `/mnt/archive`. After 60 quiet seconds the robot undocks it, and the trigger line remains.

You never added `/mnt/archive` to `/etc/fstab`. The robot docks it only when needed.

## Common pitfalls

> [!WARNING]
> - **Writing a short name in a direct map.** The key must be the full absolute path, for example `/mnt/archive`.
> - **Putting the timeout in the map file.** The timeout is an option of the master line. For `/-` it applies to every key in that map.
> - **Forgetting the reload.** The daemon keeps the old maps in memory until you run `sudo systemctl reload autofs`.
> - **Leaving a shell inside the mount.** The mount stays busy, and the 60 second timeout never fires.
> - **Mixing up the two forms.** `/-` with a short key, or a real directory with a full path key, matches nothing.

## Your mission: autofs Direct Maps & Timeouts

You can now write a direct map, set its timeout, and watch the bind mount appear and vanish. The mission asks you to make `/mnt/secure_archive` mount a local folder on demand, with a 60 second timeout, and with nothing in `/etc/fstab`.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory. It always starts clean again:

```sh
astrona destroy section-050-module-01-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-050/module-01/labs/lab-01
astrona ssh ats-004-lab-051
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-050/module-01/labs/lab-01
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-051
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-050/module-01/playground
```
