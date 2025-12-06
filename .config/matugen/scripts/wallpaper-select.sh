#!/bin/bash

CONFIG="$HOME/.cache/last_wallpaper_dir"

# Load last directory
if [[ -f "$CONFIG" ]]; then
    LAST_DIR=$(cat "$CONFIG")
    if [[ -d "$LAST_DIR" ]]; then
        cd "$LAST_DIR" 2>/dev/null
    fi
fi

IMAGE=$(yad --file --add-preview --large-preview --width=1000 --height=600 \
            --title="Choose wallpaper" \
            --file-filter="Images | *.png *.jpg *.jpeg *.webp *.bmp")

[[ -n "$IMAGE" ]] && {
    dirname "$IMAGE" > "$CONFIG"
    matugen image "$IMAGE" -t scheme-tonal-spot
#-t scheme-content
#-t scheme-expressive
#-t scheme-fidelity
#-t scheme-fruit-salad
#-t scheme-monochrome
#-t scheme-neutral
#-t scheme-rainbow
#-t scheme-tonal-spot
}
