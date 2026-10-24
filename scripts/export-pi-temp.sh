#!/bin/bash

set -e

OUT="/var/lib/node_exporter/textfile_collector/raspberrypi.prom"
TMP="${OUT}.tmp"

TEMP=$(vcgencmd measure_temp | sed -E "s/temp=([0-9.]+).*/\1/")
THROTTLED_HEX=$(vcgencmd get_throttled | cut -d= -f2)

if [ "$THROTTLED_HEX" = "0x0" ]; then
    THROTTLED=0
else
    THROTTLED=1
fi

cat > "$TMP" <<EOF
# HELP raspberrypi_cpu_temperature_celsius Raspberry Pi CPU temperature
# TYPE raspberrypi_cpu_temperature_celsius gauge
raspberrypi_cpu_temperature_celsius $TEMP

# HELP raspberrypi_throttled Raspberry Pi throttling/undervoltage flag
# TYPE raspberrypi_throttled gauge
raspberrypi_throttled $THROTTLED
EOF

mv "$TMP" "$OUT"
