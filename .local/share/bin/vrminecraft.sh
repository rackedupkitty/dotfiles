#!/usr/bin/env bash

# Start cleanup watcher FIRST (background)
~/.local/share/bin/minecraft-java-cleanup.sh &

# Launch TLauncher (blocking – required for xdotool timing)
/usr/bin/tlauncher

# Give UI time to settle
sleep 0.5

# VR click automation (this is why blocking matters)
xdotool mousemove 1400 1000 click 1
