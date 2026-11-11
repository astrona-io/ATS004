# Writing and changing a lab

Teach each outcome before asking the learner to perform it. Keep the question, worked solution, grader and lifecycle scenario aligned. A lesson should link to the practice that uses it, and the lab should link back to the relevant explanation. Update `coverage.md` when outcomes or environments change.

Use a small independent lab for one skill and a capstone for combinations. Use QEMU when the learner needs a kernel, bootloader, systemd, disks, PAM, security policy or routed network. Use kind when a future exercise actually needs Kubernetes. A container inside the VM can provide another distribution's package manager; explain that boundary explicitly.

Use disk serials and `/dev/disk/by-id` for destructive storage commands. Verify the device is the lab disk before formatting it. Keep the management network reachable while testing a private network or firewall. Preserve enforcement and test actual permitted and denied operations for security tasks.

Bootstrap prepares the broken or incomplete starting point. It must not perform the student's repair. Reference solutions run as `student` and use the same commands and privileges taught to the learner. A grader must inspect evidence without repairing the task. Return exit 1 with a specific `FAIL:` reason for an unfinished outcome; execution and infrastructure failures must not masquerade as expected student mistakes.

Add a `testing/scenario.json` with an intended initial failure, the reference solution and negative cases for realistic wrong fixes. Restore after each negative case, then require every grader to pass. Add a real reboot when persistence is promised. A configuration-file match alone is not proof of live behavior or successful boot. Add a focused smoke script when a playground needs a prepared service or fixture.

Keep infrastructure assumptions in `validation-and-releases.md`. Do not describe a check as passing until its runtime evidence exists. Preserve failed-run logs long enough to diagnose bootstrap, grading, restore and cleanup separately.
