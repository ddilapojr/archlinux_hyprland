#!/bin/bash

# Configuration
SHOW_HEADER=false

# Find the num lock LED device
find_num_led() {
    for led in /sys/class/leds/*numlock*/brightness; do
        if [ -e "$led" ]; then
            echo "$led"
            return 0
        fi
    done
    echo ""
    return 1
}

send_notification() {
    local state=$1
    local title=""
    local state_text=""
    
    if [ "$state" = "1" ]; then
        state_text="ON"
    else
        state_text="OFF"
    fi
    
    title="Num Lock: $state_text"
    
    gdbus call --session \
        --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.Notify \
        "num-lock-osd" 0 "" "$title" "" "[]" \
        "{'x-canonical-private-synchronous': <'num-lock'>}" 1500 >/dev/null 2>&1
}

# Find num lock LED
NUM_LED=$(find_num_led)

if [ -z "$NUM_LED" ]; then
    echo "Error: Could not find num lock LED device"
    echo "Available LED devices:"
    ls -la /sys/class/leds/ 2>/dev/null || echo "None found"
    exit 1
fi

echo "Using LED device: $NUM_LED"

# Get initial state
previous_state=$(cat "$NUM_LED" 2>/dev/null || echo "0")

# Monitor for num lock changes
while true; do
    current_state=$(cat "$NUM_LED" 2>/dev/null || echo "0")
    
    if [ "$current_state" != "$previous_state" ]; then
        send_notification "$current_state"
        previous_state=$current_state
    fi
    
    sleep 0.2
done
