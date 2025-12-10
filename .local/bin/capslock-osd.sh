#!/bin/bash

CAPS_LED=$(ls /sys/class/leds/*{capsl*,CapsL*}*/brightness 2>/dev/null | head -n1)
[ -z "$CAPS_LED" ] && { echo "No Caps Lock LED found"; exit 1; }

prev=0

while :; do
    curr=$(cat "$CAPS_LED" 2>/dev/null || echo 0)
    if [ "$curr" != "$prev" ]; then
        gdbus call --session --dest org.freedesktop.Notifications \
            --object-path /org/freedesktop/Notifications \
            --method org.freedesktop.Notifications.Notify \
            "capslock-osd" 0 "" "$([ "$curr" = 1 ] && echo "Talk" || echo "SCREAM")" "" "[]" "{}" 800 >/dev/null
        prev="$curr"
    fi
    sleep 0.2
done