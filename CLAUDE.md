# Writing style for this repo

All study text here (course pages, lab docs, READMEs, comments in YAML and
scripts) is for people learning a technical subject, often for a
certification exam. Many of them are not native English speakers and have no
university degree.

## Plain English

Write the text in Plain English for a general adult audience (18+) without a
university degree. The content must be highly accessible and easy to
understand for non-technical readers, without feeling childish.

Strict guidelines:

1. Target a Flesch-Kincaid Grade Level of 8 or 9 (equivalent to a standard
   newspaper article).
2. Avoid all technical jargon, acronyms, and corporate buzzwords. If a
   technical term is necessary, explain it immediately using an everyday
   analogy.
3. Keep sentences conversational and direct. Split long sentences into two.
4. Use short paragraphs (max 3-4 sentences per paragraph) and clear
   subheadings to make the text scannable.
5. Use the active voice (e.g., "We did this" instead of "This was done by us").

## How this applies to course material

- **Know which file you are in.** A module has a short landing page and a few
  deep-dive parts. The landing page is a map: goals, what to know first, the
  order of the parts, where it fits. The real teaching goes in the parts. A lab
  has a task, a step-by-step solution and a short intro. Keep each file to its
  job. Do not add "Prerequisite: ... Next: ..." navigation lines to pages;
  the landing page and the course outline already give the order.
- **Keep each part short.** One idea per part, about 5 to 8 minutes of
  reading and at most about 8 command blocks, so a learner can finish it with
  the playground in one sitting of about 15 minutes. Split at a natural seam
  where each half ends with something the learner has seen work. Never split
  only to hit a number. When you split, renumber the files, fix every "Part N"
  reference in the module, the wrap-up links and `astrona.yaml`.
- **Every heading gets an intro.** A `##` section that has `###`
  subsections starts with one to three sentences that say what the section
  is about and why it matters, before the first `###`. Never put a `###`
  directly under a `##`.
- **Every module stands on its own.** Never refer to other sections or
  modules: no "see section 040", "as module 3 showed", "you met this in
  section 000", and no links to pages in another module. If the reader needs
  a fact from elsewhere, state the fact directly in one or two sentences.
  This also goes for parts of the same module: never write "Part 2 shows",
  "from Part 1" or "as in Part 3". Say the fact itself ("the commands below
  need the filesystem mounted at `/mnt/data`"). The wrap-up page is the one
  exception: it recaps each part and links to it.
  The landing page does not have a "Where this fits" section.
- **Write words out in full.** Do not use informal short forms in prose:
  write "communications", "configuration", "repository", "administrator",
  "for example" and "that is", never "comms", "config", "repo", "admin",
  "e.g." or "i.e.". Names in code, commands and file paths stay as they are.
- **Exam terms stay.** The product's own names are what the reader must learn
  (for example a resource kind, a field, a command). Keep them, but explain
  each one in plain words, with an everyday analogy, the first time it appears
  in a file. Spell out acronyms on first use, with a short plain meaning.
- **Analogies come from space, and the reader is an astronaut.** When a term
  needs an everyday picture, use space: spaceships, planets, solar systems,
  space stations, mission control, signals, docking, star charts, airlocks,
  even the Death Star. Talk to the reader as an astronaut (for example "your
  first mission", "astronaut, check your flight log"), but not in every
  sentence. Requests are **signals** that ships send to each other. Use one
  analogy per hard idea, keep it short, and keep it the same everywhere (if
  the repository has an analogy glossary, use it). The analogy helps the reader; it
  never replaces the real term, and it never changes code or output.
- **Show one real example before the rule.** Start with a concrete case the
  reader can run, then give the general rule.
- **Say which part does the work.** Readers often mix up the parts of a system
  that sit close together. Whenever something happens, say which component
  did it.
- **Never change code to fit the style.** Commands, configuration files, field
  names, resource names, log lines and command output stay exactly as they
  are. They were run and checked on a real system. Never make up command
  output. If you shorten it, say that you did.
- **Prose only.** The grade-level and sentence rules apply to explanations.
  They do not apply to code blocks, tables of field names or reference lists
  (those may stay short and dense).
- **Keep the page furniture the same.** Hands-on steps are normal page
  content, not boxes: a short `###` subsection (for example "See it in your
  playground") with one sentence saying what to do, the command, the real
  output, and one or two sentences saying what it shows. A `> [!TIP]` box is
  only for a real tip: advice the reader can reuse beyond this one step (a
  habit, a shortcut, how to spot a problem, an exam habit). Everything else
  is a normal sentence: notes about the current step ("if the log line is
  old, run it again"), background facts, optional extra steps, and plain
  information. Never a command snippet, never two in a row, and most pages
  need zero or one tip. Each part ends with a
  `## Common pitfalls` `> [!WARNING]` block for that part only. Use a Mermaid
  diagram for a flow, an order or a state change, keep it under about 12
  boxes, and follow it with one sentence that says what it shows.
- **Labs come right after the part they practise.** Do not collect all
  graded labs at the end of a module. In `astrona.yaml`, put each lab (its
  `question.md` reading and the `lab` entry) right after the reading part it
  tests. If a part teaches a gradeable skill and no lab covers it, create a
  new lab. That part then ends with a `## Your mission: <lab title>` section:
  one sentence on what the reader can now do, one on what the mission asks,
  then pause the playground (`astrona stop <playground name>`), the
  `astrona run` and `astrona submit` commands, and finally
  `astrona destroy <lab name>` plus `astrona start <playground name>`. The
  wrap-up lists the missions and ends with cleaning up the playground
  (`astrona list`, `astrona destroy <playground name>`).
- **Renew the playground before hands-on work.** Every reading part that
  runs commands has `<!-- astrona:playground:renew -->` exactly once, on its
  own line, right before the first hands-on step (the first "Save this as"
  or the first command block), so the playground timer is reset before the
  learner needs the playground. Not on landing pages (they carry
  `<!-- astrona:playground -->`), wrap-up pages or pages without commands.
- **Mermaid without HTML.** The platform renders Mermaid with HTML labels
  switched off, so `<br/>` and any other HTML tag break the drawing. Rules:
  - One line per box, no `<br/>`, no HTML. Keep the box to the thing's name
    (`"/dev/vdb"`, `"vg_data"`, `"Kernel mount table"`).
  - Put the logic on the arrows: `D -->|"mkfs.ext4"| F`,
    `P -->|"vgcreate"| V`, `C -->|"mount -t nfs"| S`. Keep edge labels short.
  - Quote every label. Prefer `flowchart TB`; use `LR` only for a short chain.
  - Sequence diagrams: short participant aliases (`participant C as client`)
    and short message text.
  - Anything longer (full device paths, UUIDs, long option strings) goes in
    the sentence under the diagram.
- **No links to outside sources.** Course pages, labs and playground docs do
  not link to or point at outside websites (the one exception is the
  `resources` field of a lab entry in `astrona.yaml`) (official docs, GitHub, blogs,
  RFCs), and they have no "Reference" or "Official docs" lists. Everything the
  reader needs is explained on the page itself. Not affected: addresses the
  reader actually uses in a command (`10.10.20.10`, `server:/nfs/share`),
  links to astrona.io platform pages, and the Mission Briefing's
  contributors and "report a mistake" links.
- **Configuration goes to a file first.** Whenever the reader should write
  a multi-line configuration file (a systemd unit, an autofs map, a
  `sysctl.d` file; in course parts, playground docs and labs), use three
  separate steps:
  1. "Save this as `/etc/systemd/system/mnt-data.mount`:" followed by a
     plain ` ```ini ` (or ` ```text `) block with only the file's contents.
     No `cat > file <<'EOF'`, no `sudo tee file <<EOF`, no shell around it.
     Say once that a file under `/etc` is saved with `sudo` (for example
     `sudo nano /etc/systemd/system/mnt-data.mount`).
  2. "Apply it:" followed by a ` ```sh ` block with only the commands that
     make the system read it (`sudo systemctl daemon-reload`,
     `sudo systemctl start mnt-data.mount`).
  3. "Then check the result:" followed by the check commands, if any.
  The path is the real path the system reads, so it also says what is being
  configured. If a value must come from the reader's machine (a UUID), use a
  placeholder like `<UUID>` in the file and say how to get the value
  (`sudo blkid /dev/vdb`); never put shell variables inside the file. Write
  a file the first time its contents appear; do not show it once "to read"
  and paste it again later. A one-line append the page already uses
  (`echo '...' | sudo tee -a /etc/fstab`) is a command and stays as it is.
  Never tell the reader to apply something from the playground's
  `examples/` folder: they start the playground with `astrona run`, so that
  folder is not on their machine.
- **Helpers have readable names.** Shell helper functions and variables use
  names that say what they do (`check_mount`, `count_inodes`,
  `$SCRATCH_DISK`), never single letters.


## About this repo (ATS004 only)

Everything above is general and can be copied to other course repositories. This
section is only true for this one.

### What the student is trying to learn

- **The goal:** pass the **Storage** domain of the **Linux Foundation
  Certified System Administrator (LFCS)** exam. It is 20% of the exam.
- **What the exam really tests:** doing storage work by hand, in a live Linux
  terminal, under time pressure, and leaving the machine in a state that
  survives a reboot. So the student must *do* things (partition, format,
  mount, encrypt, pool disks with LVM and RAID, add swap, share over NFS,
  set quotas), not just recognise words. Every explanation should lead to
  something they can run, and every change should be proved with a check
  command (`lsblk`, `findmnt`, `blkid`, `swapon --show`, `lvs`,
  `cat /proc/mdstat`, `quota`).
- **The exam topics (Storage domain):** configure and manage LVM storage;
  manage and configure the virtual filesystem; create, manage and
  troubleshoot filesystems; use remote filesystems and network block
  devices; configure and manage swap space; configure filesystem
  automounters; monitor storage performance. The README table maps each
  section to its topic.
- **The sections:**

  | Section | Title | Exam topic |
  | --- | --- | --- |
  | 010 | Local Storage Preparation & Forensics | Create, manage and troubleshoot filesystems |
  | 020 | Remote Filesystems (SSHFS and NFS) | Use remote filesystems and network block devices |
  | 030 | Dynamic & Redundant Volumes (LVM & RAID) | Configure and manage LVM storage |
  | 040 | Swap Space Management | Configure and manage swap space |
  | 050 | On-Demand Mounting (autofs) | Configure filesystem automounters |
  | 060 | Virtual Filesystems (/proc and /sys) | Manage and configure the virtual filesystem |
  | 070 | Storage Performance Monitoring | Monitor storage performance |
  | 080 | Capacity, Quotas & the Filesystem Hierarchy | Create, manage and troubleshoot filesystems |

- **The version:** every playground and lab boots **Ubuntu 24.04** in a
  QEMU virtual machine (image
  `ghcr.io/astrona-io/ubuntu-qcow2-image:24.04-lfcs-{ARCH}`). Teach the
  tools as they behave there (`util-linux`, `e2fsprogs`, `xfsprogs`,
  `lvm2`, `mdadm`, `cryptsetup`, `nfs-kernel-server`, `autofs`, systemd).
  Do not teach options or behaviour from other distributions or versions
  without saying so.
- **The main sources:** the manual pages of the tools themselves (`man 8
  mount`, `man 5 fstab`, `man 8 lvm`) and the Linux kernel documentation.
  Check every page against them.

### Space analogy glossary

Use these pictures for these terms, in every course page, lab and playground.
Keep them consistent so the astronaut builds one picture of the universe.
Most pages written before these rules have no space analogies yet; add them
when you rework a page, using this table.

**The universe**

| Term | Space picture |
| --- | --- |
| The learner | An astronaut (a cadet on their first missions) |
| Linux machine (virtual machine) | A spaceship |
| The playground or lab virtual machine | A training spaceship in the simulator |
| Kernel | The ship's core: it runs every system and decides who gets what |
| Process | A crew member doing one job |
| Process ID (PID) | The crew member's badge number |
| Signal (`SIGTERM`, `SIGKILL`) | An order to a crew member: "finish up and leave" or "out, now" |
| User and group | The crew roster and the ranks on it |
| `root` and `sudo` | The captain, and borrowing the captain's key for one order |
| Network between two virtual machines | The communications array between two ships |
| systemd | The ship's duty officer: starts every system in the right order at launch |
| Reboot | Landing and launching again: only what is written in the logbook comes back |

**Disks and filesystems**

| Term | Space picture |
| --- | --- |
| Block device / raw disk (`/dev/vdb`) | An empty cargo hold: space, but no shelves and no labels |
| Partition and partition table (MBR, GPT) | Walls that split one hold into rooms, and the deck plan that lists them |
| Filesystem (ext4, XFS, FAT32) | The shelving and labelling system built inside a hold |
| Formatting (`mkfs`) | Building the shelves; anything stored there before is lost |
| Inode | The cargo tag on each item: who owns it, its size, where it sits |
| Journal | The cargo officer's notebook: each change is written down before it is made |
| Mount and mount point | Docking a cargo hold to a hatch in the ship's one corridor (`/`) |
| `/etc/fstab` | The ship's logbook of holds to dock at every launch |
| systemd `.mount` / `.automount` unit | A duty order to dock a hold, or to dock it the moment someone knocks on the hatch |
| UUID and label | The hold's serial number and its painted name |
| `fsck` | The repair crew that walks the shelves and fixes broken tags |
| Busy mount ("target is busy") | A hold that cannot undock while crew are still inside |
| LUKS encryption | A vault door on the hold: no passphrase, no cargo |
| Keyslot | One of several keys that open the same vault door |
| `dd` disk clone | A copy of the hold made crate by crate, empty corners included |
| `tar` backup | Packing chosen items into one shipping container |

**Pooling and protecting disks**

| Term | Space picture |
| --- | --- |
| LVM | A shared cargo pool built from several holds |
| Physical volume (PV) | One hold given to the pool |
| Volume group (VG) | The pool itself: all the space from its holds together |
| Logical volume (LV) | A storage area cut from the pool, sized as you need it |
| Extent | One standard-size crate slot in the pool |
| `pvmove` | Moving crates from one hold to another while the ship flies |
| RAID (`mdadm`) | Several holds that work as one, with spare copies of the cargo |
| RAID 1 / RAID 5 | Every crate stored twice / crates spread out with a checksum crate to rebuild any one lost hold |
| Degraded array, rebuild | Flying with one hold damaged, and refilling a new hold from the others |
| Swap | Overflow storage in a hold, used when the ship's working memory is full |
| Swap priority | Which overflow hold the kernel fills first |

**Holds on other ships**

| Term | Space picture |
| --- | --- |
| Remote filesystem | A hold on another ship, reached over the communications array |
| NFS server and export (`/etc/exports`) | The ship that shares a hold, and its list of who may dock to it |
| NFS client | The ship that docks to the shared hold |
| SSHFS and FUSE | Reaching another ship's hold through your own secure channel, run by a crew member, not the core |
| autofs, master map and maps | A docking robot: it docks a hold the moment someone asks for it, following its map of which hold goes to which hatch |
| Direct map / indirect map / wildcard (`*`, `&`) | A map entry for one fixed hatch / a hatch inside a shared corridor / one rule that covers every hold by name |
| Idle timeout | The robot undocks a hold nobody has used for a while |

**Inside the core, and watching it work**

| Term | Space picture |
| --- | --- |
| `/proc` | The core's live status screens: nothing is stored, every read is a fresh reading |
| `/sys` and `sysctl` | The core's control panel, and the dials on it |
| `/etc/sysctl.d/` | The logbook page that sets the dials again at every launch |
| File descriptor | A crew member's open line to one item in a hold |
| I/O wait | Crew standing still, waiting for the cargo lift |
| `iostat`, `iotop`, `pidstat`, `lsof` | The cargo lift's gauges, and the list of which crew member is using it |
| IOPS and throughput | How many trips the lift makes, and how much cargo it moves |
| `df` and `du` | How full each hold is / how much one shelf really holds |
| Disk quota (user, group, project) | A cargo allowance per crew member, per rank, or per mission |
| Soft limit, hard limit, grace period | The warning line, the wall, and how long you may stay over the warning line |
| Symbolic link | A sign on one hatch that points to another hatch |
| Filesystem Hierarchy Standard (FHS) | The standard deck plan every Linux ship follows (`/etc`, `/var`, `/home`) |

### The training ships: playgrounds and labs

There is no sample application. Each playground and lab is one or more
**Ubuntu 24.04 virtual machines** with extra blank disks. Keep the names in
commands, paths and host names exactly as the code has them.

- **Single machine (most modules):** one virtual machine, 2 CPUs, 2 GiB of
  memory, a 15 GB system disk (`/dev/vda`) and one to four extra disks of
  1 to 4 GB. Each extra disk has a serial number in `config.yaml`
  (`serial: "s10m01-raw"`), so it is also reachable as
  `/dev/disk/by-id/virtio-<serial>`. The first extra disk is usually
  `/dev/vdb`, but pages must tell the reader to confirm it with `lsblk`.
- **Two machines on a private network:**

  | Where | Machines (name, address) | Network |
  | --- | --- | --- |
  | 020-01 playground (SSHFS) | `client` 10.10.20.5, `srv` 10.10.20.10 | `10.10.20.0/24` |
  | 020-02 playground (NFS) | `client` 10.10.20.5, `server` 10.10.20.10 | `10.10.20.0/24` |
  | 050-02 playground (autofs) | `client` 10.10.50.5, `nfs` 10.10.50.10 | `10.10.50.0/24` |
  | 020 capstone | `terminal` 10.10.40.5, `app-srv1` 10.10.40.10 | `10.10.40.0/24` |
  | 050 capstone | `data-001` 10.10.50.5, `app-srv1` 10.10.50.10 | `10.10.50.0/24` |

  The other remote-filesystem labs (020-01, 020-02, 050-01, 050-02) run on
  a single machine that plays both sides.
- **Seed data:** bootstrap scripts create the starting state (sample files
  such as `/srv/logs` on `srv`, `/nfs/share` with `report.txt` and
  `notes.txt` on `server`, `/export/eng` and `/export/mkt` on `nfs`,
  corrupted or pre-filled filesystems in labs). Read the bootstrap script
  before describing what is in the box.

### Environment facts the text must respect

- **Every runtime is QEMU, not `kind`.** There is no Kubernetes anywhere in
  this course. The reader works in a shell on the virtual machine, reached
  with `astrona ssh <name>`.
- **`astrona stop` and `astrona start` do not work for QEMU labs** (the CLI
  says so: "qemu labs aren't supported yet"). So a `## Your mission` section
  does not pause the playground. It tells the reader to remove the
  playground with `astrona destroy <playground name>` to free memory, run
  the mission, and afterwards start a fresh playground with the module's
  `astrona run ... -c .../playground` command. A playground always starts
  clean.
- **The login user has passwordless `sudo`.** Every storage command that
  touches a device, `/etc` or a mount needs `sudo`; show it in the command.
- **Device names can move.** `/dev/vdb`, `/dev/vdc` and so on follow the
  order the disks were attached. Persistent configuration (`/etc/fstab`,
  `/etc/crypttab`, `mdadm.conf`) uses `UUID=` or a label, and pages say why.
- **A reboot is the real test.** The exam checks that mounts, swap, RAID
  arrays and `sysctl` values come back after a restart. Pages that teach
  persistence should show `sudo findmnt --verify`, `sudo mount -a` or
  `sudo systemctl daemon-reload` as the safe check before any reboot.
- **Most tools are already in the image.** The LFCS image ships the
  storage tools; a few bootstrap scripts and lab solutions still install a
  package with `apt` (for example `sysstat` for `iostat`). Check the
  bootstrap script and the solution before saying a tool is or is not
  installed.

### Where things are in this repo

| What | Where |
| --- | --- |
| Course outline the platform reads: every reading page and lab, in order. Never list `solution.md` here | `astrona.yaml` |
| Overview, curriculum table, how to run things | `README.md` |
| Section overview and its modules | `sections/section-0N0/README.md` |
| Section knowledge check (scenario questions with hidden answers) | `sections/section-0N0/quiz.md` |
| Final closed-book quiz for the whole domain | `sections/final-domain-quiz.md` |
| Module reading: landing page, deep-dive parts, wrap-up | `sections/section-0N0/module-0M/course.md`, `course-0N-*.md` |
| Graded lab: task, walkthrough, setup, grader | `.../labs/lab-0N/` (`question.md`, `solution.md`, `bootstrap/`, `validation/`) |
| Ungraded sandbox for a module (every module except 010-07 and 010-08) | `.../playground/` (`config.yaml`, `bootstrap/`, `docs/overview.md` says what is in the box) |
| One graded integration lab per section | `sections/section-0N0/capstone/labs/lab-01/` |

A lab folder holds:

| Path | Purpose |
| --- | --- |
| `config.yaml` | Lab definition: QEMU runtime, extra disks, bootstrap and validation scripts; `metadata.docs` has `question: "question.md"` and `solution: "solution.md"` |
| `README.md` | Short intro with the run command |
| `question.md` | The exam-style task. Starts with `# Question` and `Solve this question on: \`terminal\`` |
| `solution.md` | Step-by-step walkthrough with real output |
| `bootstrap/` | Shell scripts that prepare the disks and the starting state, never the graded result |
| `validation/validate-completed.sh` | Grading: checks the live machine (`findmnt`, `blkid`, `swapon`, `lvs`, `/proc/mdstat` and so on) |

### Lab metadata in `astrona.yaml`

`astrona.yaml` has one entry per section under `modules:` (`module-010`,
`module-020` and so on, plus `module-090` for the final domain quiz). Each
section's `content` lists, in order: the section `README.md`, then for each
module its landing page, its parts, and right after the part a lab tests, a
`Question` reading (`labs/lab-0N/question.md`) followed by the `type: lab`
entry; the module's wrap-up page comes last. The section quiz and then the
section capstone close the section. Playgrounds are not listed: the landing
page's `<!-- astrona:playground -->` marker shows them.

Every `type: lab` entry (module labs and capstones) carries these fields, in
this order:

```yaml
      - type: reading
        title: Question
        path: sections/section-010/module-01/labs/lab-01/question.md
      - type: lab
        title: "Filesystem Creation & Mounting Sandbox Lab"
        path: sections/section-010/module-01/labs/lab-01
        difficulty: beginner
        estimated_duration: 15m
        topic: filesystems
        task_kind: build
        tags: [lsblk, blkid, mkfs, ext4, mount, findmnt]
        learning_goals:
          - Find the raw disk among the attached block devices
          - Format it with ext4 and mount it on a new directory
        resources:
          - name: "mkfs.ext4 manual page"
            url: https://man7.org/linux/man-pages/man8/mke2fs.8.html
```

- `difficulty`: `beginner`, `intermediate` or `advanced`.
- `estimated_duration`: realistic time to solve it, for example `15m`, `30m`, `45m`.
- `topic`: exactly one of `filesystems`, `partitions`, `encryption`,
  `persistent-mounts`, `backup`, `remote-filesystems`, `lvm`, `raid`,
  `swap`, `automount`, `virtual-filesystems`, `performance`, `capacity`,
  `quotas`, `links-and-hierarchy`.
- `task_kind`: exactly one of `build` (set it up from scratch),
  `troubleshooting` (find and fix what is broken) or `migration` (move
  working storage to another disk, size or layout, for example `pvmove` or
  a RAID rebuild). The platform filters labs by it, so it is a field of its
  own, never a tag.
- `tags`: 4 to 8 ids, only from the tag list below. Add a new tag to the list
  first if nothing fits.
- `learning_goals`: 2 or 3 plain sentences, each starting with a verb, saying
  what the learner proves in this lab.
- `resources`: 1 to 4 documentation pages, each with a `name` and a `url`
  that loads. This is the **only** place outside links are allowed: the
  platform shows them as optional further reading next to the lab.

**Tag list** (lower case, hyphens, never synonyms):

- Disks and partitions: `lsblk`, `blkid`, `gpt`, `mbr`, `fdisk`, `parted`,
  `partprobe`, `by-id-paths`
- Filesystems: `mkfs`, `ext4`, `xfs`, `vfat`, `inodes`, `fsck`, `tune2fs`,
  `labels`, `uuids`, `resize2fs`, `xfs-growfs`
- Mounting: `mount`, `umount`, `findmnt`, `mount-options`, `fstab`,
  `systemd-mount`, `systemd-automount`, `busy-mount`, `lsof`, `fuser`,
  `kill-signals`, `hidden-files`
- Encryption: `luks`, `cryptsetup`, `keyslots`
- Backup: `dd`, `tar`, `checksums`
- Remote: `sshfs`, `fuse`, `nfs`, `nfs-exports`, `exportfs`, `showmount`,
  `nfs-mount-options`
- LVM: `pvcreate`, `vgcreate`, `lvcreate`, `vgextend`, `vgreduce`,
  `pvmove`, `lvextend`, `lvreduce`
- RAID: `mdadm`, `raid1`, `raid5`, `mdadm-conf`, `raid-rebuild`,
  `raid-grow`, `mdadm-monitor`, `initramfs`
- Swap: `swap-file`, `swap-partition`, `mkswap`, `swapon`, `swap-priority`
- Automount: `autofs`, `auto-master`, `direct-map`, `indirect-map`,
  `wildcard-map`, `idle-timeout`
- Virtual filesystems: `procfs`, `sysfs`, `sysctl`, `sysctl-d`,
  `file-descriptors`, `proc-mounts`
- Performance: `iostat`, `iotop`, `pidstat`, `io-wait`, `disk-latency`
- Capacity and quotas: `df`, `du`, `quota`, `user-quota`, `group-quota`,
  `project-quota`, `xfs-quota`, `grace-period`
- Links and hierarchy: `symlinks`, `hard-links`, `readlink`, `find`,
  `fhs`
- Proof: `reboot-persistence`, `permissions`

### Running things

```bash
# Playground (ungraded)
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-010/module-01/playground
astrona ssh section-010-module-01-playground
astrona destroy section-010-module-01-playground   # takes metadata.name from config.yaml, not the path

# Lab or capstone (graded against the live virtual machine)
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-010/module-01/labs/lab-01
astrona submit -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-004-lab-014

# Authors: run a local, uncommitted copy, and prove a lab passes with its reference solution
astrona run -c sections/section-010/module-01/playground
astrona test -c sections/section-010/module-01/labs/lab-01
```

Names: a playground is `section-<section>-module-<module>-playground` (for
example `section-030-module-02-playground`). The first labs have numbered
names that do not follow the folder (`ats-004-lab-014` is
`section-010/module-01/labs/lab-01`, `ats-004-lab-086` is
`section-030/module-02/labs/lab-05`); always read `metadata.name` in the
lab's `config.yaml` and keep those names. A new lab takes
`ats-004-lab-<section>-<module>-<lab>`, for example
`ats-004-lab-010-05-02`, so two labs never share a name. Every lab must pass
`astrona validate` and `astrona test`.

A lab's `config.yaml` names its docs with `metadata.docs.question:
"question.md"` and `metadata.docs.solution: "solution.md"`. Never rename
these keys or the files, even if a local `astrona validate` complains.

Graders check the **live machine** (what is mounted, with which options,
which UUID is in `/etc/fstab`, which swap is active), not just that a file
exists. A lab's `question.md` and `solution.md` must match what its
`validation/` scripts actually check.

Test machines on the maintainer's computer: one lab at a time. Never touch
labs or clusters you did not create.

### Where to find trusted sources

Check facts here before writing them down. Prefer these over memory.

- **The exam itself:** the LFCS page on the Linux Foundation training site
  (<https://training.linuxfoundation.org/certification/linux-foundation-certified-sysadmin-lfcs/>)
  lists the domains and topics. The 20% weight and the section-to-topic map
  above come from this repository's README and `astrona.yaml` and have not
  been re-checked against it.
- **Manual pages (the course spine):** <https://man7.org/linux/man-pages/>,
  for example
  [mount(8)](https://man7.org/linux/man-pages/man8/mount.8.html),
  [fstab(5)](https://man7.org/linux/man-pages/man5/fstab.5.html),
  [lsblk(8)](https://man7.org/linux/man-pages/man8/lsblk.8.html),
  [mke2fs(8)](https://man7.org/linux/man-pages/man8/mke2fs.8.html),
  [e2fsck(8)](https://man7.org/linux/man-pages/man8/e2fsck.8.html),
  [lvm(8)](https://man7.org/linux/man-pages/man8/lvm.8.html),
  [mdadm(8)](https://man7.org/linux/man-pages/man8/mdadm.8.html),
  [cryptsetup(8)](https://man7.org/linux/man-pages/man8/cryptsetup.8.html),
  [swapon(8)](https://man7.org/linux/man-pages/man8/swapon.8.html),
  [exports(5)](https://man7.org/linux/man-pages/man5/exports.5.html),
  [nfs(5)](https://man7.org/linux/man-pages/man5/nfs.5.html),
  [proc(5)](https://man7.org/linux/man-pages/man5/proc.5.html),
  [systemd.mount(5)](https://www.freedesktop.org/software/systemd/man/latest/systemd.mount.html),
  [systemd.automount(5)](https://www.freedesktop.org/software/systemd/man/latest/systemd.automount.html).
- **Kernel documentation:** <https://docs.kernel.org/admin-guide/>, for
  example the `sysctl` pages
  (<https://docs.kernel.org/admin-guide/sysctl/vm.html>), the `/proc`
  filesystem page and the software RAID (`md`) page.
- **Ubuntu Server documentation:** <https://documentation.ubuntu.com/server/>
  for the Ubuntu 24.04 defaults (NFS, autofs, LVM, swap).
- **The other tools:** man7 also has `sshfs(1)`, `autofs(5)`,
  `auto.master(5)`, `exportfs(8)`, `xfs_quota(8)`, `mkfs.fat(8)`,
  `iostat(1)`, `pidstat(1)`, `iotop(8)` and the quota tools. On the lab
  machine, `man <tool>` shows the Ubuntu 24.04 version.

### Skills to use here

The `astrona-course-*` skills do most authoring jobs in this repository: planning
(`domain-plan`), creating the tree (`domain-scaffold`), building modules
(`domain-build`), deep-dive parts (`deep-dive`), labs and playgrounds (`lab`),
lab docs (`lab-docs`), challenges (`create-challenge`), quizzes
(`generate-assessment`) and fact-checking (`review-accuracy`).
