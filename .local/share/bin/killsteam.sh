#!/bin/bash

# Get the active window class
active_class=$(hyprctl activewindow -j | jq -r ".class")

# Check which window is active
if [[ "$active_class" == "steam" ]]; then
    pkill -9 steam
elif [[ "$active_class" == "org.qbittorrent.qBittorrent" ]]; then
    pkill -f qbittorrent
else
    # Default: kill whatever active window (Hyprland dispatch)
    hyprctl dispatch killactive
fi
