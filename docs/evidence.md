# Evidence and next steps

The next improvement is to attach concrete evidence to the documented work.

## Priority 1 — describe the running system

- [ ] Record OS, RAM and installed component versions.
- [ ] Map both SSDs to their roles, capacities and mount points.
- [ ] Export sanitized Compose and K3s configuration.
- [ ] Confirm Nginx/Traefik responsibilities and monitoring placement.

Do not paste full environment files, kubeconfig or unreviewed command output.

## Priority 2 — demonstrate operation and recovery

- [ ] Add a sanitized Immich screenshot using non-private sample media.
- [ ] Add a Grafana screenshot explaining the displayed workload and time range.
- [ ] Record the backup timer's schedule and last successful execution.
- [ ] Complete and document an isolated restore test.
- [ ] Capture K3s readiness and absence of the reported address error after reboot.

## Priority 3 — strengthen the engineering story

- [ ] Add dated incident notes for the next freeze.
- [ ] Record the import tool and a Google Photos sample validation.
- [ ] Compare TuneD profiles under a repeatable workload if performance tuning is still needed.

For each result, record: **what was tested, when, how, the result and the limitation**. Do not claim availability, backup reliability or performance improvements without measurements.

## Preparing the public portfolio

Before changing repository visibility, review tracked files and Git history for credentials and personal data. Replace real hostnames and IP addresses with consistent placeholders. Review screenshots separately.

The public project should contain documentation, reviewed examples and original automation that is actually used. The current repository does not yet reproduce the complete deployment.

A concise project description:

> Raspberry Pi 5 homelab for self-hosted photo storage, private remote access and Linux infrastructure operations, with documented K3s networking and reliability investigations.
