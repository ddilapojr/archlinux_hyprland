#!/bin/bash

# ============================================================================
# CONFIGURATION - Edit these values to customize
# ============================================================================

# Icon settings - Use system icon names
ICON_HIGH="audio-volume-high"
ICON_MEDIUM="audio-volume-medium"
ICON_LOW="audio-volume-low"
ICON_MUTED="audio-volume-muted"

# Display settings
TIMEOUT=1500            # Notification timeout in milliseconds

# Volume thresholds (when to switch icons)
THRESHOLD_HIGH=70       # Volume >= this uses high icon
THRESHOLD_MEDIUM=30     # Volume >= this uses medium icon (below uses low)

# ============================================================================
# Script logic - no need to edit below this line
# ============================================================================

get_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.0f", $2 * 100}'
}

is_muted() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "MUTED"
}

send_notification() {
    local volume=$(get_volume)
    
    # Send notification via D-Bus - no icon, no text, just progress bar
    gdbus call --session \
        --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.Notify \
        "volume-osd" 0 "" "" "" "[]" \
        "{'value': <$volume>, 'x-canonical-private-synchronous': <'volume'>}" "$TIMEOUT" >/dev/null 2>&1
}

# Check if wpctl is available
if ! command -v wpctl &> /dev/null; then
    echo "Error: wpctl not found. Please install wireplumber."
    exit 1
fi

# Send initial notification
send_notification

# Monitor for volume changes
pactl subscribe | grep --line-buffered "sink" | while read -r line; do
    send_notification
done