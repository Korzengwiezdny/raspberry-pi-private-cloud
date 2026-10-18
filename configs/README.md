# Configuration excerpts

These small excerpts reproduce settings recorded in the project history. They are not full exports of the running configuration or an installation kit.

| File | Destination or purpose |
| --- | --- |
| [k3s/config.example.yaml](k3s/config.example.yaml) | Merge the node address setting into the existing `/etc/rancher/k3s/config.yaml` |
| [journald/90-persistent.conf](journald/90-persistent.conf) | Recorded override in `/etc/systemd/journald.conf.d/` |
| [immich/storage.env.example](immich/storage.env.example) | Storage variables from the existing Immich `.env` |

Replace the K3s placeholder with the appropriate stable LAN address before use. Preserve unrelated local settings.

The complete Compose file, Helm values, backup script and systemd units must be reviewed from the actual installation before being published. See [Operations and recovery](../docs/operations.md) for the backup consistency and restart-handling checks.
