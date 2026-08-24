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

## The Learning & Lab Path

This section is divided into two modules, both paired with hands-on practice in the automounting laboratory environment:

### 1. On-Demand Mounting Fundamentals
*   **Module Reader:** **[Module 1: On-Demand Mounting Fundamentals](./module-01/course.md)**
*   **Associated Lab:** **`labs/lab-050` (Part I)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-050
    ```
*   **Hands-on Objective:** Install `autofs`, configure the master map `/etc/auto.master` to monitor `/mnt/auto`, and map direct/indirect on-demand triggers with automated idle timeouts.

### 2. Network Automount Maps & Tuning
*   **Module Reader:** **[Module 2: Network Automount Maps & Tuning](./module-02/course.md)**
*   **Associated Lab:** **`labs/lab-050` (Part II)**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c labs/lab-050
    ```
*   **Hands-on Objective:** Map an NFS export (`data-001:/exports/shared`) dynamically to `/mnt/auto/shared` using `autofs` custom sub-maps. Configure the mount to be automatically released and unmounted after exactly 5 minutes (300 seconds) of inactivity, with zero permanent fstab records.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the automounting lab mission:

*   **[Take the Section 050 Knowledge Check Quiz](./quiz.md)**
