# Validation and course releases

## Run a lab as a student

Use the lab's `config.yaml` directory with `astrona run -c <directory>`, then connect with `astrona ssh <environment-name>`. Follow its question and inspect the result with the commands taught in the lesson. `astrona submit -c <directory>` grades and tears down the environment; use it after completing the exercise.

The learner account is `student`. Bootstrap and grading enter that account explicitly, including its home directory. Commands that inspect protected system state use `sudo`. Multi-VM SSH access uses the student keys configured by Astrona.

## Run the author checks

Install Python 3.11 or newer and the dependencies in `scripts/ci/requirements.txt`, plus QEMU and Astrona. Linux runners need access to `/dev/kvm`; macOS uses the available QEMU accelerator. From the repository root:

```sh
python3 -m pip install -r scripts/ci/requirements.txt
python3 scripts/ci/environments.py
python3 -m unittest discover -s scripts/ci -p 'test_*.py'
python3 scripts/ci/lifecycle.py <environment-directory> --output test-results
```

The lifecycle runner refuses to replace an existing environment of the same name. It captures each command, records the source revision and whether the checkout was modified, records tool/image details, and destroys its environment even after a failed check. It does not run `astrona submit`, because verification needs the VM for later negative and reboot checks.

The `labs` workflow discovers every main-path, optional and legacy lab and every playground on pull requests, main-branch pushes, manual runs and a weekly schedule. Its final `all-environments-pass` job requires every matrix entry to pass. A missing scenario, malformed reference, unknown grader, unsuccessful bootstrap or cleanup is a failure. Logs are retained as workflow artifacts for 14 days.

## VM images

Ubuntu environments reference the dated `24.04-lfcs-20261111` amd64 and arm64 images in `ghcr.io/astrona-io/ubuntu-qcow2-image`, with a SHA-256 checksum for each disk. Updating a tag alone cannot silently change the accepted disk. These images include the LFCS tools used by the labs. Other image sources, such as the enforcing SELinux VM, are identified in their environment configuration.

The course artifact contains source material, quizzes, environment definitions, scripts and validation evidence. VM disks and containers remain external dependencies. Downloading the course does not make every bootstrap offline-capable.

## Publish an approved course version

After manual review and merge, create a version tag such as `v1.0.0`, or run `publish-course` on a revision reachable from `main` with a new version. The workflow reruns the full environment matrix for that revision before packaging it. Packaging rejects missing, duplicate or failed reports, reports from a modified checkout, and reports for another commit. Existing version tags in the registry are rejected.

The registry path is `ghcr.io/astrona-io/ats004/course:<version>`. The OCI artifact type is `application/vnd.astrona.course.v1`; it is a source bundle, not a container to start with `docker run`.

Retrieve a published version with ORAS:

```sh
oras pull ghcr.io/astrona-io/ats004/course:v1.0.0
sha256sum --check SHA256SUMS
tar -xzf course.tar.gz
```

The version above is an example, not a claim that it has been published. `course.json` records the source commit and all lifecycle results. For an immutable reference, resolve the tag with `oras resolve` and pull by its returned digest. GitHub Actions uses its scoped package token to publish to GHCR; no Docker Hub credentials are needed.

Discovery also checks `practice.yaml` replacements and rejects identical grader sets in the main course. See [optional and legacy exercises](practice-variants.md).
