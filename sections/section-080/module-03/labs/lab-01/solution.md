# Solution Guide: XFS Quotas and Project Quotas

This guide shows you how to set an XFS user quota and enforce a project quota on a directory tree.

---

## Step 1: Set alice's user quota

```bash
sudo xfs_quota -x -c 'limit bsoft=40m bhard=50m alice' /srv/xfs
```

---

## Step 2: Define the `webdata` project

Register the project's ID-to-directory mapping and its friendly name:

```bash
echo '42:/srv/xfs/webdata' | sudo tee -a /etc/projects
echo 'webdata:42' | sudo tee -a /etc/projid
```

Initialise it — this stamps the project ID onto existing files and sets the inheritance flag so new files pick it up automatically:

```bash
sudo xfs_quota -x -c 'project -s webdata' /srv/xfs
```

---

## Step 3: Cap the project

```bash
sudo xfs_quota -x -c 'limit -p bhard=100m webdata' /srv/xfs
```

---

## Step 4: Confirm

```bash
sudo xfs_quota -x -c 'report -h' /srv/xfs
sudo xfs_quota -x -c 'report -p -h' /srv/xfs
```

The user report shows alice at `40M` soft / `50M` hard. The project report shows `webdata` at `100M` hard — a cap on the whole `/srv/xfs/webdata` tree, no matter which user writes to it.
