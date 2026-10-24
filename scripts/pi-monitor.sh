#!/bin/bash

INTERVAL=30

while true; do
    clear
    echo "============================================================"

    echo "                 RASPBERRY PI MONITOR"

    echo "============================================================"

    echo "Czas: $(date)"

    echo

    echo "=== UPTIME / LOAD ==="

    uptime

    echo

    echo "=== TEMPERATURA / THROTTLING ==="

    vcgencmd measure_temp 2>/dev/null || echo "Brak vcgencmd"

    vcgencmd get_throttled 2>/dev/null || true

    echo

    echo "=== CPU ==="

    top -bn1 | grep -E '^%Cpu|^CPU' | head -1

    echo

    echo "=== RAM / SWAP ==="

    free -h

    echo

    echo "=== DYSKI ==="

    df -h -x tmpfs -x devtmpfs -x overlay

    echo

    echo "=== I/O DYSKÓW ==="

    if command -v iostat >/dev/null 2>&1; then

        iostat -dx 1 1 | grep -E 'Device|sda|sdb|nvme'

    else

        echo "Brak iostat. Zainstaluj: sudo apt install sysstat"

    fi

    echo

    echo "=== SIEĆ ==="

    ip -br addr | grep -v lo

    echo

    echo "=== TOP 10 CPU ==="

    ps -eo pid,user,%cpu,%mem,rss,comm --sort=-%cpu | head -11

    echo

    echo "=== TOP 10 RAM ==="

    ps -eo pid,user,%cpu,%mem,rss,comm --sort=-rss | head -11

    echo

    echo "============================================================"

    echo "Odświeżanie co ${INTERVAL}s | Ctrl+C aby zakończyć"

    echo "============================================================"

    sleep "$INTERVAL"

done
