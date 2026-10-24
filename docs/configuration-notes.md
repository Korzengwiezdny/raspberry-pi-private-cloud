# Homelab — opublikowane konfiguracje

Eksport sprawdzony 24 października 2026. Materiały dokumentują konfigurację z przekazanej paczki; nie stanowią potwierdzenia wykonania usług na serwerze. Skrypty zachowano bez zmian funkcjonalnych.

## Zawartość i pochodzenie

| Ścieżka w repozytorium | Oryginał na Raspberry Pi |
| --- | --- |
| `compose/immich/docker-compose.yml` | `/home/frank/immich-app/docker-compose.yml` |
| `monitoring/values.yaml` | `/home/frank/monitoring/values.yaml` |
| `scripts/backup-immich.sh` | `/home/frank/scripts/backup-immich.sh` |
| `scripts/pi-monitor.sh` | `/home/frank/pi-monitor.sh` |
| `scripts/export-pi-temp.sh` | `/usr/local/bin/export-pi-temp.sh` |
| `systemd/*` | odpowiadające pliki z `/etc/systemd/system/` |

Compose pochodzi z konfiguracji Immicha i zachowuje odnośniki do źródła. Użycie gotowej konfiguracji nie oznacza autorstwa Immicha. W repozytorium warto opisać własny wkład w instalację, przechowywanie danych, monitoring i diagnostykę.

`compose/immich/.env.example` przygotowano na potrzeby publikacji. Nie jest kopią rzeczywistego `.env`; ścieżki i wersję należy potwierdzić przed wdrożeniem. Hasło Grafany usunięto z publicznego `monitoring/values.yaml`. Pusty `/home/frank/values.yaml` pominięto.

## Co widać w konfiguracji

- Immich, machine learning, Valkey i PostgreSQL są opisane w Compose. Wersja Immicha domyślnie śledzi tag `release`; faktycznej wersji uruchomionej na serwerze nie ustalono.
- Mapowanie `2283:2283` nie ogranicza portu do localhost. Dostępność z innych urządzeń zależy również od zapory i sieci; plik nie dowodzi dostępu wyłącznie przez Tailscale.
- Monitoring ustawia Grafanę na NodePort 30300, wolumen 2 GiB, Prometheusa na 10 GiB oraz retencję 7 dni / 8 GB. Alertmanager jest wyłączony.
- Eksporter zapisuje metryki temperatury i zbiorczy wskaźnik flag `get_throttled` do pliku `.prom` przez plik tymczasowy. Timer wywołuje usługę co około 30 sekund.
- Timer kopii jest ustawiony na 03:00 z losowym opóźnieniem do 10 minut, według strefy serwera. `Persistent=true` pozwala nadrobić pominięte uruchomienie po ponownym uruchomieniu timera.

## Backup — rzeczywisty zakres i otwarte kwestie

Skrypt sprawdza punkt montowania `/srv/data`, porównuje źródło montowania ze źródłem `/`, zatrzymuje `immich-server`, kopiuje zawartość `/srv/immich-data/library/` przez `rsync -aHAX --delete`, kopiuje `.env` i Compose, a przez trap próbuje uruchomić serwer ponownie.

1. **Zrzut bazy:** skrypt nie wykonuje `pg_dump`. Może kopiować zrzuty tworzone osobno przez Immicha, jeśli są w kopiowanym katalogu. Paczka nie potwierdza harmonogramu, świeżości ani odtwarzalności tych zrzutów. Dokumentacja Immicha wymaga zarówno plików, jak i bazy.
2. **Zgodność ścieżek:** trzeba potwierdzić, że źródło `rsync` odpowiada rzeczywistemu `UPLOAD_LOCATION` i obejmuje potrzebne podkatalogi. Rzeczywisty `.env` nie był częścią przeglądu.
3. **Usuwanie:** `--delete` przenosi usunięcia ze źródła do kopii. To lustrzana kopia, bez wersjonowania mediów w tym skrypcie. Nie uruchamiaj go na przypadkowym katalogu docelowym.
4. **Uprawnienia:** usługa pracuje jako `frank`; wymaga dostępu do Dockera, pliku logu, źródła i katalogów docelowych. Skrypt nie tworzy katalogów docelowych. Sama obecność plików nie potwierdza poprawnych uprawnień.
5. **Wznowienie aplikacji:** trap jest ustawiany dopiero po poleceniu stop; błąd polecenia start jest ignorowany. Sukces kopiowania nie potwierdza, że Immich wrócił do pracy.
6. **Spójność:** zatrzymanie serwera ogranicza zapisy aplikacji, ale samo w sobie nie dowodzi spójności czasowej mediów i wcześniejszego zrzutu bazy.
7. **Odtwarzanie:** w paczce nie ma wyniku izolowanego testu odtworzenia ani konfiguracji kopii poza hostem.

## Ograniczenia metryk

`raspberrypi_throttled` przyjmuje 1 dla dowolnego wyniku innego niż `0x0`. `get_throttled` zawiera również bity historyczne; ta metryka nie oznacza wyłącznie aktualnego throttlingu. Warto później rozdzielić poszczególne flagi.

## Co uzupełnić

- Wynik odtworzenia danych w osobnym środowisku i zmierzony czas.
- Potwierdzenie harmonogramu i świeżości kopii bazy.
- Użyte wersje Immicha, K3s oraz chartu kube-prometheus-stack.
- Manifesty własnego workloadu Nginx i oczyszczony eksport dashboardu.
- Sposób instalacji i faktyczne uprawnienia skryptów.

Nie ma tu manifestów K3s, konfiguracji Tailscale, reguł zapory ani logów diagnostycznych. Nie należy sugerować, że sam zestaw odtwarza cały homelab.

## Źródła

- Immich backup and restore: https://docs.immich.app/administration/backup-and-restore/
- Raspberry Pi vcgencmd: https://www.raspberrypi.com/documentation/computers/os.html
