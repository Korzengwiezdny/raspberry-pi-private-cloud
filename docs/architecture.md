# Architecture

## Workload boundaries

The Raspberry Pi 5 hosts an Immich installation managed through Docker Compose. The project directory recorded in the operating notes is `~/immich-app`; `/srv/immich-data` is the path used when checking available storage.

PostgreSQL holds application metadata, while Valkey supports the application's queue/cache layer. The actual Compose file is needed to document image versions, service names, volume mappings and the complete service set. Immich's library and database must both be considered when planning recovery.

K3s is also part of the homelab. Its presence should not be confused with an Immich deployment on Kubernetes.

## Storage

Two SSDs are included in the project. Their capacities, interfaces, mount points and individual roles still need to be recorded from the host. No RAID, replication or independent backup arrangement is claimed.

| Item to record | Why it matters |
| --- | --- |
| SSD model, capacity and connection | Identify the storage and USB adapter involved in faults |
| Mount point and filesystem | Map application data to physical storage |
| Role of each disk | Distinguish system, library, database and backup data |
| Backup location and retention | Establish which failures the backup can survive |

Use stable identifiers for local mounts; device names such as `/dev/sda` can change. Keep serial numbers and UUIDs in private inventory if they are unnecessary for the public explanation.

## Access and proxy routing

Local access uses Immich's port 2283. Remote access uses Tailscale and an HTTPS hostname within the tailnet. Public documentation represents these as:

- `http://<PI_LAN_IP>:2283`
- `https://<IMMICH_TAILSCALE_HOSTNAME>`

Nginx and Traefik were included in the project discussion, but their actual responsibilities and the TLS termination point still need to be checked. Do not infer public Internet exposure, an ingress route or a specific TLS mechanism from the hostname alone.

## Monitoring

Prometheus, Grafana and kube-prometheus-stack are in the project scope. The namespace, Helm release, storage configuration, retention and active alerts remain to be documented.

Useful evidence includes memory pressure, disk space, CPU load, node readiness and restarts during an incident. A monitoring service on the affected host can stop at the same time as the host; an external availability check is a useful follow-up.

## Configuration still to capture

- OS distribution/release, kernel, RAM and EEPROM version.
- Docker, Compose, Immich and K3s versions.
- Sanitized Compose configuration and storage mapping.
- Which proxy serves each endpoint.
- Monitoring deployment location and persistent storage.
- Actual backup script, systemd units and retention settings.

Only examples that match the running installation should become deployment instructions.
