#!/bin/bash

send_notification() {
    local volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.0f", $2 * 100}')
    
    gdbus call --session \
        --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.Notify \
        "volume-osd" 0 "" "Volume" "" "[]" \
        "{'value': <$volume>, 'x-canonical-private-synchronous': <'volume'>}" 1500 >/dev/null 2>&1
}

# Check wpctl
command -v wpctl &>/dev/null || { echo "wpctl not found"; exit 1; }

# Initial
send_notification

# React instantly, no polling
pactl subscribe 2>/dev/null | grep --line-buffered "change.*sink" | while read -r; do
    send_notification
done