#!/usr/bin/env bash

# Check release
if [ ! -f /etc/arch-release ] ; then
    exit 0
fi

# Source variables
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalcontrol.sh"
get_aurhlpr
export -f pkg_installed
fpk_exup="pkg_installed flatpak && flatpak update"

# Define packages to ignore
ignore_pkgs="hyprpicker opera spotify spicetify-cli spotify-adblock discord visual-studio-code-bin whatsdesk-bin chromium morgen-bin gimp hyprland hyprutils aquamarine hyprgraphics hyprland-guiutils hyprland hyprtoolkit hyprwire xdg-desktop-portal-hyprland hyprlang"
aur_ignore_pkgs="hyprpicker opera spotify spicetify-cli spotify-adblock discord visual-studio-code-bin whatsdesk-bin chromium morgen-bin"

# Trigger upgrade
if [ "$1" == "up" ] ; then
    trap 'pkill -RTMIN+20 waybar' EXIT
    command="
    fastfetch --logo-type kitty --logo-width 0 --logo-preserve-aspect-ratio true
    $0 upgrade
    ${aurhlpr} -Syu --ignore ${ignore_pkgs// /,}
    $fpk_exup
    read -n 1 -p 'Press any key to continue...'
    "
    kitty --title systemupdate sh -c "${command}"
fi

# Check for AUR updates (excluding ignored packages)
aur=$(${aurhlpr} -Qua | grep -v -E "$(echo ${aur_ignore_pkgs} | sed 's/ /|/g')" | wc -l)

# Check for official repo updates (excluding ignored packages)
ofc=$( (while pgrep -x checkupdates > /dev/null ; do sleep 1; done) ; checkupdates | grep -v -E "$(echo ${ignore_pkgs} | sed 's/ /|/g')" | wc -l)

# Check for Flatpak updates
if pkg_installed flatpak ; then
    fpk=$(flatpak remote-ls --updates | wc -l)
    fpk_disp="\n󰏓 Flatpak $fpk"
else
    fpk=0
    fpk_disp=""
fi

# Calculate total available updates (excluding ignored packages)
upd=$(( ofc + aur + fpk ))

# Display update info when triggered with "upgrade"
if [ "${1}" == "upgrade" ] ; then
    printf "[Official] %-10s\n[AUR]      %-10s\n[Flatpak]  %-10s\n" "$ofc" "$aur" "$fpk"
    exit
fi

# Show tooltip
if [ $upd -eq 0 ] ; then
    upd="" # Remove Icon completely
    # upd="󰮯"   # If zero, display icon only
    echo "{\"text\":\"$upd\", \"tooltip\":\" Packages are up to date\"}"
else
    echo "{\"text\":\"󰮯 $upd\", \"tooltip\":\"󱓽 Official $ofc\n󱓾 AUR $aur$fpk_disp\"}"
fi
