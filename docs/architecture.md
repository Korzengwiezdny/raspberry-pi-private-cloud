# Architecture

## Host and storage

The host is a Raspberry Pi 5 with 8 GB RAM running Raspberry Pi OS Lite from an SSD, without an SD card. The project notes describe two SSDs of approximately 447 GB each; exact models and OS release remain to be captured.

| Disk | Recorded role | Paths | Observed USB link |
| --- | --- | --- | --- |
| System SSD | OS, Docker, K3s and active Immich data | `/`, `/boot/firmware`, `/srv/immich-data` | 5000M |
| Backup SSD | Local backup destination, ext4 | `/srv/data` | 480M |

These are observed link speeds, not measured application throughput. Device names changed or could change between boots, so the second disk is mounted by UUID. Its recorded fstab options are `defaults,noatime,nofail 0 2`. The actual UUID is omitted.

`/srv/data` is a mount point. `/srv/immich-data` is a directory on the root filesystem and therefore resides on the system SSD.

```text
System SSD
├── Raspberry Pi OS Lite, Docker and K3s
└── /srv/immich-data
    ├── library
    └── postgres

Backup SSD mounted at /srv/data
└── backups/immich
    ├── files
    └── config
```

## Immich and the storage migration

Immich uses the official Docker Compose installation approach, with its project in `~/immich-app`. Services include the server, machine learning, PostgreSQL and Valkey. PostgreSQL persists through a bind mount.

Active data originally lived at `/srv/data/immich`. During migration, Immich was stopped and data copied with rsync; `--numeric-ids` preserved PostgreSQL's numeric UID/GID ownership. The resulting environment paths were:

```dotenv
UPLOAD_LOCATION=/srv/immich-data/library
DB_DATA_LOCATION=/srv/immich-data/postgres
```

The old data was temporarily retained at `/srv/data/immich-migration-copy`. Its current presence is not established; it should not be counted as an independent backup.

The layout separates active data from the backup disk. Both SSDs still depend on the same host and location.

## Network paths

| Service | Recorded access path |
| --- | --- |
| Immich on LAN | `http://<PI_LAN_IP>:2283` |
| Immich through Tailscale | `https://<IMMICH_TAILSCALE_HOSTNAME>` |
| Serve proxy target | `http://127.0.0.1:2283` |
| Test Nginx | LAN HTTP → Traefik Ingress → ClusterIP Service → Nginx Deployment |
| Grafana | `http://<PI_LAN_IP>:30300`, NodePort |
| Prometheus | ClusterIP service on port 9090 |

Tailscale was installed on the Pi, phone and laptop. Serve provides the recorded HTTPS proxy for Immich; Traefik belongs to the K3s test web path. The project record does not establish a publicly exposed Internet endpoint.

## K3s and monitoring

K3s runs separately from the Compose-managed Immich stack. An early memory-cgroup issue was addressed by adding `cgroup_memory=1 cgroup_enable=memory` to the existing boot command line and rebooting. The record subsequently reports the node as Ready.

Helm installed `prometheus-community/kube-prometheus-stack` with release name `monitoring` in namespace `monitoring`. Persistent storage was configured as 10 GiB for Prometheus and 2 GiB for Grafana. The underlying storage class and volume paths are not included in the record.

This monitoring covers Linux and K3s, but detailed Immich Docker Compose container metrics were identified as a separate improvement.

A host script at `/usr/local/bin/export-pi-temp.sh` writes temperature/throttling metrics to `/var/lib/node_exporter/textfile_collector`. A systemd timer refreshes the output every 30 seconds, and Helm values were adjusted for the collector.

## Remaining inventory

Capture exact OS/kernel and component versions, SSD models, Helm values, storage class, Compose definitions and systemd unit names from the host. The conversation records a K3s version string, but a fresh version output is preferable before presenting a pinned reproducible deployment.
