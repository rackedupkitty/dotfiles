#!/usr/bin/env bash

# Disable animations
hyprctl keyword animations:enabled 0

# Switch workspace
hyprctl dispatch workspace "$1"

# Re-enable animations (small delay helps avoid jank)
sleep 0.05
hyprctl keyword animations:enabled 1
