#!/usr/bin/env bash
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

WALL_DIR="$HOME/pictures/wallpapers"

# Spare wallpapers, rotated across any extra (non-laptop, non-ultrawide) monitor.
SPARES=(
    "enterprise_a_blue.png"
    "enterprise_blue_multiplanets.png"
    "two_ships.png"
)

# The laptop (eDP-1) and Iiyama ultrawide keep the wallpapers assigned statically
# in hyprpaper's config (home.nix); this script only touches the extras.
apply_wallpapers() {
    sleep 1  # let Hyprland/hyprpaper settle after start/hotplug

    local n=${#SPARES[@]}
    local i=0
    # Sorted by name for deterministic rotation across plug/unplug cycles.
    while IFS=$'\t' read -r name desc; do
        [ "$name" = "eDP-1" ] && continue
        case "$desc" in *Iiyama*) continue ;; esac

        local file="${SPARES[$(( i % n ))]}"
        hyprctl hyprpaper preload "$WALL_DIR/$file" >/dev/null 2>&1
        hyprctl hyprpaper wallpaper "$name,$WALL_DIR/$file" >/dev/null 2>&1
        ((i++))
    done < <(hyprctl monitors -j | jq -r 'sort_by(.name) | .[] | "\(.name)\t\(.description)"')
}

case "$1" in
    daemon)
        apply_wallpapers  # cover being docked at login
        socat - UNIX-CONNECT:"$SOCKET" | while read -r line; do
            case "${line%%>>*}" in
                monitoradded|monitorremoved|monitorremovedv2) apply_wallpapers ;;
            esac
        done
        ;;
    apply) apply_wallpapers ;;
esac
