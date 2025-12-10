#!/bin/bash

NUM_LED=$(ls /sys/class/leds/*{numl*,NumL*}*/brightness 2>/dev/null | head -n1)
[ -z "$NUM_LED" ] && { echo "No Num Lock LED found"; exit 1; }

prev=0

while :; do
    curr=$(cat "$NUM_LED" 2>/dev/null || echo 0)
    if [ "$curr" != "$prev" ]; then
        gdbus call --session --dest org.freedesktop.Notifications \
            --object-path /org/freedesktop/Notifications \
            --method org.freedesktop.Notifications.Notify \
            "numlock-osd" 0 "" "$([ "$curr" = 1 ] && echo "Num Lock: On" || echo "Num Lock: Off")" "" "[]" "{}" 800 >/dev/null

        prev="$curr"
    fi
    sleep 0.2
done