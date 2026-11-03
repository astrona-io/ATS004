# Solution Walkthrough

Four moves: make the directories, move the files, make one hard link, and make two symbolic links. After each step you can run `astrona submit -c sections/section-080/module-04/labs/lab-02` to see what the grader still misses.

---

## Step 1: Move the files to their places

```sh
sudo mkdir -p /etc/acme /var/log/acme /var/lib/acme
sudo mv /srv/staging/acme.conf /etc/acme/
sudo mv /srv/staging/acme-report /usr/local/bin/
sudo mv /srv/staging/acme.log /var/log/acme/
sudo mv /srv/staging/inventory.db /var/lib/acme/
ls -l /srv/staging
```

The standard deck plan gives each kind of item its own deck: settings in `/etc`, programs added by hand in `/usr/local/bin`, logs in `/var/log`, and data that changes in `/var/lib`. `mv` keeps the file mode, so `acme-report` stays executable. The staging directory is now empty.

---

## Step 2: Make the hard link

```sh
sudo ln /etc/acme/acme.conf /var/lib/acme/acme.conf.keep
stat -c '%i %h %n' /etc/acme/acme.conf /var/lib/acme/acme.conf.keep
```

`ln` with no switch makes a hard link: a second name for the same cargo tag. Both lines show the same inode number and a link count of `2`.

---

## Step 3: Make the two symbolic links

```sh
sudo ln -s /usr/local/bin/acme-report /usr/local/bin/acme
sudo ln -s /var/log/acme/acme.log /var/lib/acme/current.log
ls -l /usr/local/bin/acme /var/lib/acme/current.log
readlink -f /usr/local/bin/acme
acme
```

`ln -s TARGET LINKNAME` makes a symbolic link: a sign on one hatch that points to another hatch. The target comes first, and the name of the new link comes second. `ls -l` shows each link with an arrow, and `readlink -f` prints the real file at the end of the chain. Running `acme` prints the report. Run `astrona submit` for the final grade.
