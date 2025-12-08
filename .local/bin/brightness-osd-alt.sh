#!/bin/bash

# ============================================================================
# CONFIGURATION - Edit these values to customize
# ============================================================================

# Icon settings - Use system icon names
ICON_HIGH="display-brightness-high"
ICON_MEDIUM="display-brightness-medium"
ICON_LOW="display-brightness-low"
ICON_OFF="display-brightness-off"

# Display settings
TIMEOUT=1500            # Notification timeout in milliseconds

# Brightness thresholds (when to switch icons)
THRESHOLD_HIGH=70       # Brightness >= this uses high icon
THRESHOLD_MEDIUM=30     # Brightness >= this uses medium icon (below uses low)
THRESHOLD_OFF=5         # Brightness <= this uses off icon

# Message format
SHOW_PERCENTAGE=true    # Show percentage in notification (true/false)

# ============================================================================
# Script logic - no need to edit below this line
# ============================================================================

get_brightness() {
    brightnessctl get | awk -v max="$(brightnessctl max)" '{printf "%.0f", ($1/max)*100}'
}

send_notification() {
    local brightness=$(get_brightness)
    local icon=""
    local message=""
    
    if [ "$brightness" -le "$THRESHOLD_OFF" ]; then
        icon="$ICON_OFF"
    elif [ "$brightness" -ge "$THRESHOLD_HIGH" ]; then
        icon="$ICON_HIGH"
    elif [ "$brightness" -ge "$THRESHOLD_MEDIUM" ]; then
        icon="$ICON_MEDIUM"
    else
        icon="$ICON_LOW"
    fi
    
    if [ "$SHOW_PERCENTAGE" = true ]; then
        message="${brightness}%"
    else
        message=""
    fi
    
    # Send notification via D-Bus
    gdbus call --session \
        --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.Notify \
        "brightness-osd" 0 "$icon" "" "$message" "[]" \
        "{'value': <$brightness>, 'x-canonical-private-synchronous': <'brightness'>}" "$TIMEOUT" >/dev/null 2>&1
}

# Check if brightnessctl is available
if ! command -v brightnessctl &> /dev/null; then
    echo "Error: brightnessctl not found. Please install it: sudo pacman -S brightnessctl"
    exit 1
fi

# Send initial notification
send_notification

# Monitor for brightness changes using inotify
DEVICE=$(brightnessctl --list | grep -oP "Device '.*?'" | head -1 | cut -d"'" -f2)
BRIGHTNESS_PATH="/sys/class/backlight/$DEVICE/brightness"

if [ ! -f "$BRIGHTNESS_PATH" ]; then
    # Fallback: try to find any backlight device
    BRIGHTNESS_PATH=$(find /sys/class/backlight/*/brightness 2>/dev/null | head -1)
fi

if [ -f "$BRIGHTNESS_PATH" ]; then
    inotifywait -m -e modify "$BRIGHTNESS_PATH" 2>/dev/null | while read -r; do
        send_notification
    done
else
    echo "Error: Could not find brightness device path"
    exit 1
fi