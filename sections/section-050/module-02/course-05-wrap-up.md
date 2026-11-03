# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about the docking robot reaching holds on another ship: NFS exports named in an `autofs` map.

**From [Discovering Exports and Writing a Map](./course-01-discovering-and-submap.md):**

- `showmount -e nfs` lists the server's exports and who may use them.
- A map line is a key, comma-joined options with no spaces, and a target such as `nfs:/export/eng`. `intr` is a no-op.

**From [Idle Unmount and a Server That Stops Answering](./course-02-idle-unmount-and-server-loss.md):**

- The timeout on the master line undocks idle mounts, NFS included.
- A `hard` mount waits for a lost server. A `soft` mount gives up with an error, so use it only for read-only data.

**From [Wildcards: One Line for Many Exports](./course-03-wildcards.md):**

- `*` matches any name and `&` is replaced with that name. One line covers every export.
- The idle timeout is set on the master line, for example `--timeout=120`.

**From [Exceptions: One Key With Its Own Options](./course-04-exceptions-and-precedence.md):**

- An explicit key beats the wildcard, wherever it sits in the file.
- A docked mount keeps its old options until it is undocked.

## Your missions

You proved the skill in a graded mission, right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Network autofs Wildcard Mounts](./labs/lab-01/README.md) | Wildcards: One Line for Many Exports | write an indirect wildcard map for `/mnt/net` with `*` and `&`, and a 120 second timeout |

If you skipped it, go back to it now. It is short, and the exam asks for exactly this skill.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. How do you list the exports of an NFS server called <code>nfs</code>?</summary>

Run `showmount -e nfs`.
</details>

<details>
<summary>2. What does <code>&amp;</code> mean in <code>nfs:/export/&amp;</code>?</summary>

It is replaced with the text the `*` key matched. For a request for `mkt`, it becomes `nfs:/export/mkt`.
</details>

<details>
<summary>3. Where do you set the idle timeout, and what must you do after changing it?</summary>

On the master line in `/etc/auto.master`, for example `--timeout=120`. Then run `sudo systemctl reload autofs`.
</details>

<details>
<summary>4. A map has an explicit <code>eng</code> line and a <code>*</code> line. Which does a request for <code>eng</code> use?</summary>

The explicit line. The wildcard answers only for names with no explicit line.
</details>

<details>
<summary>5. When is <code>soft</code> a safe choice?</summary>

For read-only mounts. No write is waiting, so a timeout loses nothing. For writable data use `hard`.
</details>

## Clean up the playground

Land your training ships before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-050-module-02-playground
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-004-lab-052
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the mission from this module. You can start the playground again at any time with the `astrona run` command from the end of the mission. It always starts clean.
