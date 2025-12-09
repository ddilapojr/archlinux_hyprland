#!/bin/bash

# Configuration
SHOW_HEADER=true

send_notification() {
    local volume=$1
    local title=""
    
    if [ "$SHOW_HEADER" = true ]; then
        title="Volume"
    fi
    
    gdbus call --session \
        --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.Notify \
        "volume-osd" 0 "" "$title" "" "[]" \
        "{'value': <$volume>, 'x-canonical-private-synchronous': <'volume'>}" 1500 >/dev/null 2>&1
}

# Check if wpctl exists
if ! command -v wpctl &> /dev/null; then
    echo "Error: wpctl not found. Please install wireplumber."
    exit 1
fi

# Get initial volume and send notification
volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.0f", $2 * 100}')
send_notification "$volume"

# Monitor for volume changes - extract volume directly from each event line
pactl subscribe | grep --line-buffered "Event 'change' on sink" | while read -r line; do
    volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.0f", $2 * 100}')
    send_notification "$volume"
done