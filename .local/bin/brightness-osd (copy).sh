#!/bin/bash

get_brightness() {
    brightnessctl -m | cut -d',' -f4 | tr -d '%'
}

send_notification() {
    local brightness=$(get_brightness)
    
    gdbus call --session \
        --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.Notify \
        "brightness-osd" 0 "" "Brightness" "" "[]" \
        "{'value': <$brightness>, 'x-canonical-private-synchronous': <'brightness'>}" 1500 >/dev/null 2>&1
}

# Check if brightnessctl exists
if ! command -v brightnessctl &> /dev/null; then
    echo "Error: brightnessctl not found. Please install brightnessctl."
    exit 1
fi

# Send initial notification
send_notification

# Monitor for brightness changes using inotify
brightnessctl -m | tail -n +2 | while read -r line; do
    send_notification
done