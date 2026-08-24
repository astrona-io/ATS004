# Section 050: On-Demand Mounting (autofs)

Welcome to Section 050. In this section, we explore how to automate network storage connections dynamically.

In Section 020, we learned how to mount remote NFS shares. However, listing network shares inside the permanent `/etc/fstab` table presents a massive production risk: if the remote storage server goes offline, or if your local server experiences a network hiccup during boot, the local server will hang indefinitely while waiting for the remote share to respond.

To prevent boot hangs and stale connection freezes, we use **autofs**. Instead of mounting shares permanently, `autofs` monitors your directories and automatically mounts remote shares *only* when an application tries to access them, cleanly unmounting them after a defined period of inactivity.

---

## What You Will Master

By completing this section, you will acquire three core storage automation capabilities:
*   **On-Demand Mounting:** How to configure the VFS layer to trigger dynamic mounting when a directory path is entered or queried.
*   **Automount Configuration:** How to define parent directories in the master map (`/etc/auto.master`) and map specific remote hosts inside sub-maps.
*   **Inactivity Pruning:** How to configure automatic timeouts to safely unmount remote connections and free local network resources.

---

## The Learning Path

This section is organized into a single comprehensive guide:

*   **[Module 1: Filesystem Automount with autofs](./module-01)**
    Learn how VFS suspends and triggers paths. Master the master map syntax, custom map rules, NFS client optimization flags, and safety timeouts.

---

## Hands-On Practice Mission

Once you have read through the narrative guide, you are ready to configure automounting for an active network:

*   **[Go to Lab 050](../../labs/lab-050)**: Configure `autofs` to dynamically mount an NFS share on demand and auto-unmount it after 5 minutes of silence.
