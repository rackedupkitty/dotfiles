#!/usr/bin/env bash

# 1. STRIP STEAM'S INJECTIONS
# This stops Steam from forcing its overlay into Electron, 
# which is what creates the infinite loop on the second launch.
unset LD_PRELOAD
unset LD_LIBRARY_PATH

# 2. Kill ONLY exact binary name instances (restored your exact logic)
pkill -TERM -x Water.AppImage 2>/dev/null

# 3. Wait for real process to disappear
for i in {1..30}; do
    pgrep -x Water.AppImage >/dev/null || break
    sleep 0.1
done

# 4. Hard cleanup if something is stuck
pkill -KILL -x Water.AppImage 2>/dev/null

# 5. Launch 100% clean with zero extra arguments
exec /usr/bin/Water.AppImage
