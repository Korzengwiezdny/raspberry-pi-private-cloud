#!/usr/bin/env bash

set -Eeuo pipefail

SOURCE="/srv/immich-data/library/"
DEST="/srv/data/backups/immich/files/"
CONFIG_DEST="/srv/data/backups/immich/config/"
COMPOSE_DIR="/home/frank/immich-app"
LOG_FILE="/var/log/immich-backup.log"

exec >> "$LOG_FILE" 2>&1

echo
echo "===== Backup rozpoczęty: $(date --iso-8601=seconds) ====="

# Nie wykonuj backupu, jeśli dysk docelowy nie jest zamontowany.
if ! mountpoint -q /srv/data; then
    echo "BŁĄD: /srv/data nie jest zamontowane."
    exit 1
fi

# Chroni przed przypadkowym zapisaniem backupu na dysku systemowym.
if [[ "$(findmnt -n -o SOURCE /srv/data)" == "$(findmnt -n -o SOURCE /)" ]]; then
    echo "BŁĄD: katalog backupowy znajduje się na dysku systemowym."
    exit 1
fi

# Zatrzymujemy tylko serwer Immich, aby podczas kopiowania
# nie przybywały nowe zdjęcia ani zmiany metadanych.
cd "$COMPOSE_DIR"
docker compose stop immich-server

cleanup() {
    docker compose start immich-server >/dev/null 2>&1 || true
}
trap cleanup EXIT

# Kopia biblioteki, miniaturek, profili, filmów i zrzutów bazy.
rsync -aHAX --delete \
    --exclude='.immich' \
    "$SOURCE" "$DEST"

# Kopia konfiguracji.
install -m 600 "$COMPOSE_DIR/.env" "$CONFIG_DEST/immich.env"
install -m 644 "$COMPOSE_DIR/docker-compose.yml" \
    "$CONFIG_DEST/docker-compose.yml"

sync

echo "Backup zakończony: $(date --iso-8601=seconds)"
