# Section 080: Filesystem Hierarchy and Directory Sizing

Welcome to Section 080. This section covers navigating the layout of a standard Linux system and aggressively auditing space when a disk fills up. You will learn to measure physical directory consumption, traverse filesystem boundaries safely, and manage the complex network of symbolic links holding the operating system together.

## Section Objectives

By the end of this section, you will master the following competencies:
* Audit storage consumption accurately using `du` and `sort`.
* Prevent disastrous, system-halting disk crawls by restricting searches to single mount boundaries using the `-x` flag.
* Navigate the Filesystem Hierarchy Standard (FHS) confidently.
* Identify, resolve, and safely manage symbolic links without accidentally destroying target data.

## Modules

### [Module 1: Directory Capacity Auditing](./module-01/course.md)
* **Analogy:** Rolling real cargo scales into physical warehouse rooms.
* **Core Topics:** Standard directory sizing (`du`), depth limits (`-d 1`), numerical sorting (`sort -hr`), and using the `-x` flag to prevent walking across mount boundaries.

### [Module 2: Navigating Shortcuts: Symbolic Links & FHS](./module-02/course.md)
* **Analogy:** Navigating teleporter portals versus standard inventory shelves.
* **Core Topics:** FHS layouts, locating active symlinks (`find -maxdepth 1 -type l`), resolving targets (`readlink`), and understanding the catastrophic danger of trailing slashes when deleting symlinks.

## Lab Exercise

Apply your knowledge in a practical environment:
* **[Lab 080: Filesystem Hierarchy and Directory Sizing](../../labs/lab-080/README.md)**: Practice diagnosing a full root partition, tracking down hidden multi-gigabyte log directories, and navigating the core FHS symlink structures safely.
