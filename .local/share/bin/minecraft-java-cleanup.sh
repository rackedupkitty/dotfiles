#!/usr/bin/env bash

MC_SEEN=false
NO_WINDOW_SECONDS=0
NO_WINDOW_GRACE=10

# Wait until either TLauncher or Minecraft appears
while true; do
  hyprctl clients | grep -qi "tlauncher" && break
  hyprctl clients | grep -q "class: Minecraft" && break
  sleep 1
done

# Main monitoring loop
while true; do
  HAS_MC=$(hyprctl clients | grep -q "class: Minecraft" && echo yes || echo no)
  HAS_TL=$(hyprctl clients | grep -qi "tlauncher" && echo yes || echo no)

  if [ "$HAS_MC" = "yes" ]; then
    MC_SEEN=true
    NO_WINDOW_SECONDS=0
  fi

  if [ "$HAS_MC" = "no" ] && [ "$HAS_TL" = "no" ]; then
    NO_WINDOW_SECONDS=$((NO_WINDOW_SECONDS + 1))
  else
    NO_WINDOW_SECONDS=0
  fi

  [ "$NO_WINDOW_SECONDS" -ge "$NO_WINDOW_GRACE" ] && break

  sleep 1
done

# Cleanup only if Minecraft actually ran
if [ "$MC_SEEN" = true ]; then
  pkill -9 -u "$USER" java
fi
