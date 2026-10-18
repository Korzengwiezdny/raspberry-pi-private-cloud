# Operations and recovery

## Application and host checks

Run these on the existing host:

```sh
cd ~/immich-app
docker compose ps
docker compose logs --tail=200 immich-server
df -h / /srv/data
findmnt /srv/data
free -h
systemctl --failed
```

The recorded reboot check confirmed that the backup disk mounted and Immich, K3s, Tailscale, Serve configuration and the backup timer came back automatically.

## Recorded backup sequence

| Time | Action | Retention or destination |
| --- | --- | --- |
| 02:00 daily | Immich's built-in database dump | 14 dumps |
| 03:00 daily | systemd-triggered local backup | Second SSD under `/srv/data/backups/immich` |

The schedule is recorded without an explicit timezone; verify the host timezone when reviewing the actual units.

The script `~/scripts/backup-immich.sh` stops `immich-server`, copies files with rsync, copies `.env` and `docker-compose.yml`, then restarts the server. Its log is `/var/log/immich-backup.log`.

- Source library: `/srv/immich-data/library/`
- File destination: `/srv/data/backups/immich/files/`
- Configuration destination: `/srv/data/backups/immich/config/`

The raw PostgreSQL data directory is `/srv/immich-data/postgres`; the described backup relies on the database dump rather than claiming that this live directory is safely copied.

### What still needs a recovery test

The 02:00 dump and 03:00 file copy occur at different times. Stopping the application for the file copy does not retroactively make the earlier dump match that copy. Verify the actual dump path, its inclusion in the backup, and the consequences of writes between the two jobs.

The original script and units are not included in the transcript. Review them for destination mount checks, exit-code handling, overlap prevention, and guaranteed application restart if copying fails. In particular, `nofail` allows the host to boot without the backup SSD; a job must not silently copy into an unmounted directory on the root disk.

A restore test should recover a database dump and media into an isolated installation and check sample photos, videos and metadata. Record versions, date, elapsed time and the outcome. No successful restore test, off-device copy, or file-backup retention policy is documented yet.

The configuration backup includes secrets in `.env`; keep that backup private and restrict access. For version-specific recovery behavior, consult [Immich backup and restore](https://docs.immich.app/administration/backup-and-restore/).

## Timer and log inspection

```sh
systemctl list-timers --all
sudo tail -n 100 /var/log/immich-backup.log
journalctl --list-boots
journalctl --disk-usage
sudo journalctl -k -b -1 --no-pager
```

Find the actual unit names before inspecting their service journals. Review outputs privately before sharing.

## Monitoring

```sh
sudo k3s kubectl get nodes -o wide
sudo k3s kubectl get pods -n monitoring
sudo k3s kubectl get pvc -n monitoring
```

Recorded custom metric names:

```promql
raspberrypi_cpu_temperature_celsius
raspberrypi_throttled
```

The temperature exporter runs every 30 seconds. Check its implementation before interpreting the throttling value as a simple boolean; the original script is not included.

Grafana graphs represent sampled data and query windows. Compare them with terminal measurements over the same interval rather than expecting an instantaneous match. The Node Exporter Full dashboard (ID 1860) was suggested; its import is not confirmed.

## Persistent journald

The diagnostic work found a vendor drop-in selecting `Storage=volatile`. The recorded fix was `/etc/systemd/journald.conf.d/90-persistent.conf`:

```ini
[Journal]
Storage=persistent
SystemMaxUse=500M
RuntimeMaxUse=100M
```

The journal directory was created, permissions initialized with systemd-tmpfiles, journald restarted and the journal flushed. A retained previous boot still needs to be captured as evidence. A hard hang can prevent the final messages from being written.

## Experiments and planned work

**TuneD:** balanced, network-throughput and throughput-performance were discussed, as were custom pi-turbo and pi-eco profiles using performance and ondemand/schedutil governors. Application of these custom profiles and measured gains are not confirmed. Avoid changing several power-management settings during fault isolation.

**Google Photos:** the proposed route was Google Takeout → immich-go → Immich. Import completion is not recorded. Test a small batch for dates, metadata, videos and duplicates. Re-encoded or edited copies can differ at the file level even if they depict the same photo.

**Future work:** restore testing, alerts, dedicated Immich metrics, Argo CD/GitOps, access-policy refinement and CI/CD were suggestions, not completed features.
