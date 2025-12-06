#!/usr/bin/env python3
import gi
gi.require_version('Gtk', '3.0')
gi.require_version('GdkPixbuf', '2.0')
from gi.repository import Gtk, GdkPixbuf
import subprocess
import os
import random

CONFIG = os.path.expanduser("~/.cache/last_wallpaper_dir")
SCHEME_CONFIG = os.path.expanduser("~/.cache/last_wallpaper_scheme")
MODE_CONFIG = os.path.expanduser("~/.cache/last_wallpaper_mode")
TRANSITION_CONFIG = os.path.expanduser("~/.cache/last_wallpaper_transition")

# Load last directory
last_dir = os.path.expanduser("~")
if os.path.exists(CONFIG):
    with open(CONFIG, 'r') as f:
        saved_dir = f.read().strip()
        if os.path.isdir(saved_dir):
            last_dir = saved_dir

# Load last scheme
last_scheme = "scheme-expressive"
if os.path.exists(SCHEME_CONFIG):
    with open(SCHEME_CONFIG, 'r') as f:
        last_scheme = f.read().strip()

# Load last mode
last_mode = "dark"
if os.path.exists(MODE_CONFIG):
    with open(MODE_CONFIG, 'r') as f:
        last_mode = f.read().strip()

# Load last transition
last_transition = "random"
if os.path.exists(TRANSITION_CONFIG):
    with open(TRANSITION_CONFIG, 'r') as f:
        last_transition = f.read().strip()

dialog = Gtk.FileChooserDialog(
    title="Choose wallpaper",
    action=Gtk.FileChooserAction.OPEN
)
dialog.add_buttons(
    Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL,
    Gtk.STOCK_OPEN, Gtk.ResponseType.OK
)

# Set up file filter
filter_images = Gtk.FileFilter()
filter_images.set_name("Images")
filter_images.add_pattern("*.png")
filter_images.add_pattern("*.jpg")
filter_images.add_pattern("*.jpeg")
filter_images.add_pattern("*.webp")
filter_images.add_pattern("*.bmp")
dialog.add_filter(filter_images)

# Set directory
dialog.set_current_folder(last_dir)

# Add preview
preview = Gtk.Image()
dialog.set_preview_widget(preview)
dialog.set_use_preview_label(False)

def update_preview(dialog):
    filename = dialog.get_preview_filename()
    try:
        pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_size(filename, 300, 300)
        preview.set_from_pixbuf(pixbuf)
        dialog.set_preview_widget_active(True)
    except:
        dialog.set_preview_widget_active(False)

dialog.connect("update-preview", update_preview)

# Add extra widgets box
box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)

# Scheme dropdown
scheme_label = Gtk.Label(label="Scheme:")
box.pack_start(scheme_label, False, False, 0)

scheme_combo = Gtk.ComboBoxText()
schemes = [
    "scheme-expressive",
    "scheme-content",
    "scheme-fidelity",
    "scheme-fruit-salad",
    "scheme-monochrome",
    "scheme-neutral",
    "scheme-rainbow",
    "scheme-tonal-spot"
]
for scheme in schemes:
    scheme_combo.append_text(scheme)

# Set to last used scheme
try:
    scheme_index = schemes.index(last_scheme)
    scheme_combo.set_active(scheme_index)
except ValueError:
    scheme_combo.set_active(0)

box.pack_start(scheme_combo, True, True, 0)

# Mode dropdown
mode_label = Gtk.Label(label="Mode:")
box.pack_start(mode_label, False, False, 0)

mode_combo = Gtk.ComboBoxText()
modes = ["dark", "light"]
for mode in modes:
    mode_combo.append_text(mode)

# Set to last used mode
try:
    mode_index = modes.index(last_mode)
    mode_combo.set_active(mode_index)
except ValueError:
    mode_combo.set_active(0)

box.pack_start(mode_combo, True, True, 0)

# Transition dropdown
transition_label = Gtk.Label(label="Transition:")
box.pack_start(transition_label, False, False, 0)

transition_combo = Gtk.ComboBoxText()
transitions = [
    "random",
    "simple",
    "fade",
    "left",
    "right",
    "top",
    "bottom",
    "wipe",
    "wave",
    "grow",
    "center",
    "any",
    "outer",
    "none"
]
for transition in transitions:
    transition_combo.append_text(transition)

# Set to last used transition
try:
    transition_index = transitions.index(last_transition)
    transition_combo.set_active(transition_index)
except ValueError:
    transition_combo.set_active(0)

box.pack_start(transition_combo, True, True, 0)

dialog.set_extra_widget(box)
box.show_all()

response = dialog.run()
if response == Gtk.ResponseType.OK:
    image_path = dialog.get_filename()
    scheme = scheme_combo.get_active_text()
    mode = mode_combo.get_active_text()
    transition = transition_combo.get_active_text()
    
    # If random is selected, pick a random transition (excluding "random" itself)
    if transition == "random":
        actual_transitions = [t for t in transitions if t != "random"]
        transition = random.choice(actual_transitions)
    
    # Save directory
    with open(CONFIG, 'w') as f:
        f.write(os.path.dirname(image_path))
    
    # Save scheme
    with open(SCHEME_CONFIG, 'w') as f:
        f.write(scheme)
    
    # Save mode
    with open(MODE_CONFIG, 'w') as f:
        f.write(mode)
    
    # Save transition (save what was selected, not the random result)
    with open(TRANSITION_CONFIG, 'w') as f:
        f.write(transition_combo.get_active_text())
    
    # Run matugen
    subprocess.run(["matugen", "image", image_path, "-t", scheme, "-m", mode])
    
    # Run swww
    subprocess.run(["swww", "img", image_path, "--transition-type", transition])

dialog.destroy()