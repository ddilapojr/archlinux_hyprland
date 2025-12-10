#!/bin/bash

send_notification() {
    local brightness=$(brightnessctl -m | cut -d',' -f4 | tr -d '%')
    
    gdbus call --session \
        --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.Notify \
        "brightness-osd" 0 "" "Brightness" "" "[]" \
        "{'value': <$brightness>, 'x-canonical-private-synchronous': <'brightness'>}" 1500 >/dev/null 2>&1
}

# Check brightnessctl
command -v brightnessctl &>/dev/null || { echo "brightnessctl not found"; exit 1; }

# Initial
send_notification

# React instantly, no polling
inotifywait -qq -e close_write /sys/class/backlight/*/brightness |
    while read -r; do
        send_notification
    done