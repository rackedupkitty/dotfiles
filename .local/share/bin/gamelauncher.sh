#!/usr/bin/env sh

# set variables
MODE=${1:-5}

scrDir=`dirname "$(realpath "$0")"`

source $scrDir/globalcontrol.sh

ThemeSet="${confDir}/hypr/themes/theme.conf"
RofiConf="${confDir}/rofi/steam/gamelauncher_${MODE}.rasi"

# --- LOCAL STATE FILE FOR RECENT GAMES ---
HistoryFile="$HOME/.local/state/rofi_games_history.txt"
mkdir -p "$(dirname "$HistoryFile")"
touch "$HistoryFile"

# steam paths
SteamLib="$HOME/.local/share/Steam/config/libraryfolders.vdf"
SteamThumb="$HOME/.local/share/Steam/appcache/librarycache"

# steam userdata
SteamUser=$(find "$HOME/.local/share/Steam/userdata" \
    -mindepth 1 \
    -maxdepth 1 \
    -type d | head -n1)

SteamGrid="${SteamUser}/config/grid"
ShortcutVDF="${SteamUser}/config/shortcuts.vdf"

steamlaunch="steam"

# rofi override
elem_border=$(( hypr_border * 2 ))
icon_border=$(( elem_border - 3 ))

# We add rigid constraints (columns, lines, fixed-height) to stop Rofi from 
# collapsing the top row dynamically. It will now force a 5x2 grid.
r_override="element{border-radius:${elem_border}px;} element-icon{border-radius:${icon_border}px;} listview{columns:5; lines:2; flow:horizontal; fixed-columns:true; fixed-height:true;}"

fn_steam() {
    # steam library paths
    SteamPaths=`grep '"path"' "$SteamLib" | awk -F '"' '{print $4}'`

    # Official games
    GameList=$(find $SteamPaths/steamapps/ -maxdepth 1 -type f -name "appmanifest_*.acf" | while read acf; do
        appid=`grep '"appid"' "$acf" | cut -d '"' -f 4`
        game=`grep '"name"' "$acf" | cut -d '"' -f 4`
        
        # skip junk
        echo "$game" | grep -Eiq 'runtime|proton|steamvr|steam vr|linux runtime|sniper|soldier|scout|redistributable' && continue
        
        img="${SteamThumb}/${appid}/library_600x900.jpg"
        
        echo "steam|$game|$appid|$img"
    done)

    # Shortcuts
    ShortcutList=$(python3 - <<EOF
import struct, os
vdf_path = "${ShortcutVDF}"
grid = "${SteamGrid}"
if os.path.isfile(vdf_path):
    with open(vdf_path, "rb") as f: vdf = f.read()
    ptr = 0
    while True:
        idx = vdf.find(b"appid\x00", ptr)
        if idx == -1: break
        try:
            appid = struct.unpack("<I", vdf[idx + 6:idx + 10])[0]
            name_start = vdf.find(b"AppName\x00", idx) + 8
            name_end = vdf.find(b"\x00", name_start)
            game = vdf[name_start:name_end].decode("utf-8", "ignore")
            img = next((f"{grid}/{appid}p.{ext}" for ext in ["png", "jpg"] if os.path.isfile(f"{grid}/{appid}p.{ext}")), "")
            rungameid = (appid << 32) | 0x02000000
            
            print(f"shortcut|{game}|{rungameid}|{img}")
            ptr = name_end
        except: ptr = idx + 1
EOF
    )

    # 1. Get raw alphabetical list
    RawList=$(printf "%s\n%s\n" "$GameList" "$ShortcutList" | awk -F'|' 'NF==4' | sort -t '|' -k 2 -f)

    # 2. Extract previously played games based on the History file
    SortedList=""
    while read -r id; do
        [ -z "$id" ] && continue
        # Find the matching game line using the ID
        match=$(echo "$RawList" | awk -F'|' -v id="$id" '$3 == id {print $0}')
        if [ -n "$match" ]; then
            SortedList=$(printf "%s\n%s" "$SortedList" "$match")
        fi
    done < "$HistoryFile"

    # 3. Get the remaining unplayed games (Filter out ones already in history)
    if [ -s "$HistoryFile" ]; then
        RestList=$(awk -F'|' 'NR==FNR{history[$1]; next} !($3 in history)' "$HistoryFile" <(echo "$RawList"))
    else
        RestList="$RawList"
    fi

    # 4. Combine History + Alphabetical Remainder
    FullList=$(printf "%s\n%s\n" "$SortedList" "$RestList" | sed '/^$/d')

    # Pass to Rofi
    RofiSel=$(echo "$FullList" | while IFS='|' read type game appid img; do
        [ -z "$game" ] && continue
        [ -f "$img" ] && echo -en "$game\x00icon\x1f${img}\n" || echo "$game"
    done | rofi -dmenu -theme-str "${r_override}" -config $RofiConf)

    if [ -n "$RofiSel" ]; then
        launchdata=$(echo "$FullList" | awk -F'|' -v game="$RofiSel" '$2 == game {print $1 "|" $3; exit}')
        launchtype=$(echo "$launchdata" | cut -d'|' -f1)
        launchid=$(echo "$launchdata" | cut -d'|' -f2)
        
        # --- UPDATE PLAY HISTORY ---
        # Strip exact matching ID from history to avoid duplicates, then prepend to top
        grep -v "^${launchid}$" "$HistoryFile" > "${HistoryFile}.tmp" 2>/dev/null || true
        echo "$launchid" | cat - "${HistoryFile}.tmp" > "$HistoryFile"
        
        notify-send -a "t1" "Launching ${RofiSel}..."
        
        if [ "$launchtype" = "steam" ]; then
            steam -silent -applaunch "$launchid" &
        else
            steam -silent "steam://rungameid/$launchid" &
        fi
    fi
}

# verify steam
if [ ! -f $SteamLib ] || [ ! -d $SteamThumb ] ; then
    notify-send -a "t1" "Steam library not found!"
    exit 1
fi

fn_steam
