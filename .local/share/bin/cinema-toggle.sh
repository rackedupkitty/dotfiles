#!/usr/bin/env bash

STATE_FILE="/tmp/monitor_toggle_state"

# If the state file doesn't exist (e.g. on reboot), check for VIRTUAL-1 to figure out where we are
if [ ! -f "$STATE_FILE" ]; then
    if hyprctl monitors -j | grep -q "VIRTUAL-1"; then
        echo "CINEMA" > "$STATE_FILE"
    else
        echo "MIRRORED" > "$STATE_FILE"
    fi
fi

STATE=$(cat "$STATE_FILE")

if [ "$STATE" = "CINEMA" ]; then

    # 1. Going from Cinema -> Mirrored (YOUR EXACT ORIGINAL IF BLOCK)
    echo "MIRRORED" > "$STATE_FILE"

    # Save current workspace to prevent jumping
    current_ws=$(hyprctl activeworkspace -j | jq -r '.id')

    # Move VIRTUAL-1 off-screen first to free up 0x0
    hyprctl keyword monitor "VIRTUAL-1, 2560x1440@60, 5000x0, 1"

    # Restore physical displays: DP-3 at 180Hz and TV mirroring DP-3
    hyprctl keyword monitor "DP-3, 2560x1440@180, 0x0, 1"
    hyprctl keyword monitor "HDMI-A-1, 3840x2160@29.97, auto, 1, mirror, DP-3"

    # Clean up the virtual monitor backend
    sleep 0.4
    hyprctl output remove VIRTUAL-1

    # Re-enable standard animations directly without full config reload
    hyprctl keyword animations:enabled 1

    # Restore original workspace
    hyprctl dispatch workspace "$current_ws"

elif [ "$STATE" = "MIRRORED" ]; then

    # 2. Going from Mirrored -> Monitor Only (THE NEW 3RD STATE)
    echo "DP3_ONLY" > "$STATE_FILE"

    # Save current workspace to prevent jumping
    current_ws=$(hyprctl activeworkspace -j | jq -r '.id')

    # Monitor ON, TV OFF
    hyprctl keyword monitor "DP-3, 2560x1440@180, 0x0, 1"
    hyprctl keyword monitor "HDMI-A-1, disable"

    # Restore original workspace
    hyprctl dispatch workspace "$current_ws"

elif [ "$STATE" = "DP3_ONLY" ]; then

    # 3. Going from Monitor Only -> Cinema (YOUR EXACT ORIGINAL ELSE BLOCK)
    echo "CINEMA" > "$STATE_FILE"

    # Save current workspace to prevent jumping
    current_ws=$(hyprctl activeworkspace -j | jq -r '.id')

    # Switch to Headless Mode: Create VIRTUAL-1 and place it off-screen at 5000x0 first
    hyprctl output create headless VIRTUAL-1
    hyprctl keyword monitor "VIRTUAL-1, 2560x1440@60, 5000x0, 1"

    # Now disable DP-3. Workspaces cleanly transition to VIRTUAL-1 instead of scattering.
    hyprctl keyword monitor "DP-3, disable"

    # Snap VIRTUAL-1 back to 0x0 and mirror the TV
    hyprctl keyword monitor "VIRTUAL-1, 2560x1440@60, 0x0, 1"
    hyprctl keyword monitor "HDMI-A-1, 3840x2160@29.97, auto, 1, mirror, VIRTUAL-1"

    # Disable animations during cinema mode to prevent 24Hz sluggishness/stutter
    hyprctl keyword animations:enabled 0

    # Allow the headless output surface time to initialize in Wayland
    sleep 0.6

    # Pull active wallpaper from HyDE cache and apply it to VIRTUAL-1
    wall_path=$(readlink -f ~/.cache/hyde/wall.set 2>/dev/null)
    if [ ! -f "$wall_path" ]; then
        wall_path=$(readlink -f ~/.config/hyde/theme/wall.set 2>/dev/null)
    fi

    if [ -f "$wall_path" ]; then
        swww img "$wall_path" -o VIRTUAL-1 --transition-type none &
    fi

    # Restore original workspace
    hyprctl dispatch workspace "$current_ws"

fi
