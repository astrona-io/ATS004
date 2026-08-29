# Ad-Hoc Mounting with SSHFS — Playground

- **ID:** PLAYGROUND
- **Slug:** section-020-module-01-playground
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground — clean environment, no task, no grading



A two-VM sandbox (`client` + `srv` on a private subnet) that spins up, runs OS
prep, and stays running so you can explore SSHFS on a clean machine. Nothing to
submit. See [`docs/overview.md`](docs/overview.md) for the topology.

## Run it

```sh
astrona run -c .
astrona destroy section-020-module-01-playground
```

`astrona destroy` takes the environment name (`metadata.name` = `section-020-module-01-playground`), not
the config path. `astrona submit` and `astrona test` do not apply — there is no
grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (two-VM runtime + per-VM bootstrap) |
| `bootstrap/client/` | OS prep for the SSHFS client VM |
| `bootstrap/srv/` | OS prep for the SSH host VM |
| `docs/overview.md` | Topology, what is installed, ideas to try |
