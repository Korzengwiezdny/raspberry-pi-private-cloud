# Operations and recovery

These checks are intended for the existing host. No installation or infrastructure change is performed by this repository.

## Check the application and host

```sh
cd ~/immich-app
docker compose ps
docker compose logs --tail=200 immich-server

df -h / /srv/immich-data
free -h
systemctl --failed
```

Review log output privately before sharing it. A running container alone does not prove that photo uploads and background jobs work.

## Check K3s

```sh
sudo k3s kubectl get nodes -o wide
sudo k3s kubectl get pods -A
sudo journalctl -u k3s -b --no-pager -n 200
```

Record the installed version and relevant timestamps with diagnostic results.

## Backup and restore

The project includes work on an Immich backup scheduled through a systemd timer. The exact unit name, schedule, destination and retention policy have not yet been captured here.

A recovery procedure must cover the media files, database and configuration needed to rebuild the installation. Use the [Immich backup and restore documentation](https://docs.immich.app/administration/backup-and-restore/) appropriate to the installed version. A successful copy operation is not evidence of a successful restore.

Validation to record:

1. The destination is the expected mounted disk and has adequate free space.
2. The job exits successfully and creates the expected backup artifacts.
3. Database and library data are captured consistently.
4. An isolated restore recovers a sample of photos, videos and metadata.
5. The restore date, software version, elapsed time and any failures are recorded.

Do not publish database dumps or media backups. Record the outcome of the test, not private data.

To discover the actual timer:

```sh
systemctl list-timers --all
```

Then inspect the identified service's status and journal locally.

## Persistent logs

Retaining journald data across reboots is important for the freeze investigation. Verify persistence rather than assuming it:

```sh
journalctl --list-boots
journalctl --disk-usage
sudo journalctl -k -b -1 --no-pager
sudo journalctl -b -1 -p warning --no-pager
```

The project notes discuss `Storage=persistent` and `/var/log/journal`. Confirm the effective configuration, storage limit and availability of a previous boot after a controlled restart. A hard hang can still prevent the last messages from reaching disk.

## Performance experiments

TuneD discussions included `balanced`, `network-throughput` and `throughput-performance`, plus proposed `pi-eco`, `pi-turbo` and `pi-transfer` profiles. Custom profiles and performance gains are not yet verified.

Compare one change at a time using the same workload. Record the active profile, CPU load, temperature and transfer rate. Wi-Fi or encryption may limit transfers before SSD throughput becomes relevant. A profile called “turbo” does not itself imply CPU overclocking.

## Google Photos migration

The planned import workflow starts with retaining the original Google Takeout export and testing a small batch. Check dates, metadata, videos, album behavior and duplicates before a full import. Record the actual importer and its version when chosen; migration completion is not yet documented.
