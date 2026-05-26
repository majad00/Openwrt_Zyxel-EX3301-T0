#!/bin/sh

ENABLED=$(uci -q get wireless.mesh.enabled)
if [ "$ENABLED" != "1" ]; then
    # Mesh is disabled
    exit 0
fi

if ping -c 3 -W 5 8.8.8.8 >/dev/null 2>&1; then
    # Internet is working
    exit 0
else

    logger -t "MESH-WATCHDOG" "Internet unreachable! Triggering wifi-backhaul.sh recovery..."
    /etc/init.d/network restart
        sleep 5
    /usr/bin/wifi-backhaul.sh
fi

