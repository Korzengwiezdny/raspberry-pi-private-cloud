# Evidence and next steps

## Recorded milestones

- [x] Raspberry Pi 5 with 8 GB RAM and SSD-booted Raspberry Pi OS Lite.
- [x] Separate system/data and local-backup SSD roles.
- [x] Active Immich data migrated with ownership preservation.
- [x] Immich deployed with Docker Compose and mobile access configured.
- [x] Tailscale Serve configured for private HTTPS access.
- [x] K3s plus a test Nginx/Traefik route.
- [x] kube-prometheus-stack installed with persistent Prometheus and Grafana storage.
- [x] Temperature/throttling textfile metrics added with a 30-second timer.
- [x] Database dump and local backup schedules configured.
- [x] Autostart checked after reboot.
- [x] Stale K3s IPv6 address removed in the post-restart address list.

These milestones reflect the supplied project record, including a reconstructed summary of early stages. They are not a new audit of the live server.

## Next evidence to collect

- [ ] Record current OS, kernel, component versions and SSD models.
- [ ] Add the actual sanitized Compose file, Helm values and systemd units.
- [ ] Review the backup script and confirm that database dumps reach the destination.
- [ ] Test database/media consistency across the 02:00 and 03:00 jobs.
- [ ] Complete an isolated restore and record the result.
- [ ] Establish file-backup retention and an off-device copy.
- [ ] Capture retained previous-boot journals after a controlled restart.
- [ ] Add non-private Immich and Grafana screenshots with dates and context.
- [ ] Continue the unresolved freeze and mobile-upload investigations.

## Proposed development

Google Photos import with immich-go, TuneD profiles, alerts, detailed Immich container monitoring, GitOps through Argo CD and CI/CD were discussed. List them as completed only after implementation and verification.

For every experiment, record the workload, change, observation interval, result and limitation. Avoid invented uptime, performance or recovery metrics.

## Portfolio description

> Built a Raspberry Pi 5 homelab with Immich on Docker Compose, private HTTPS access through Tailscale Serve, and a K3s monitoring stack. Configured separate SSD roles and scheduled local backups, and documented storage migration, persistent logging and Kubernetes node-address troubleshooting.

## Publication review

Keep the full conversation, production configuration, environment files, media, database dumps and raw logs private. Review screenshots and Git history as well as the latest files before making the repository public.

Examples use placeholders for addresses, hostnames and UUIDs. The excerpts in this repository are not a complete installation or recovery procedure.
