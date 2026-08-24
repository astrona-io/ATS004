# Section 030: Dynamic Volume Management (LVM)

Welcome to Section 030. In this section, we solve one of the greatest challenges of traditional system administration: static partition boundaries.

If you allocate 50GB to a traditional partition, and that partition fills up, you are facing a labor-intensive and risky migration to expand it—even if you have 100GB of empty space sitting unused on a neighboring drive. 

To solve this, Linux employs **LVM (Logical Volume Manager)**. LVM abstracts raw hardware, allowing you to pool physical disks together and slice out flexible, dynamic "logical volumes" that can be expanded or shrunk instantly—even while applications are actively reading and writing to them.

---

## What You Will Master

By completing this section, you will acquire three core dynamic storage capabilities:
*   **LVM Architecture Design:** How to structure and manage Physical Volumes (PVs), Volume Groups (VGs), and Logical Volumes (LVs).
*   **Live Data Migration:** How to migrate active storage extents from one physical disk to another on the fly with zero downtime using `pvmove`.
*   **Volume Pool Reduction:** How to safely shrink Volume Groups and remove physical hardware from active storage pools.

---

## The Learning Path

This section is organized into a single comprehensive guide:

*   **[Module 1: LVM Volume Groups and Logical Volumes](./module-01)**
    Master the mechanics of Physical Extents (PEs), the LVM currency. Learn how to allocate volumes, expand pools, format logical devices, and safely migrate disk data during live maintenance.

---

## Hands-On Practice Mission

Once you have read through the narrative guide, you are ready to test your dynamic storage administration skills in a live scenario:

*   **[Go to Lab 030](../../labs/lab-030)**: Safely migrate active volume blocks off a target disk, reduce a Volume Group, and carve out a new LVM device.
