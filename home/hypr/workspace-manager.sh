#!/usr/bin/env bash
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

init_monitors() {
    sleep 0.5  # let Hyprland settle after start/reconnect
    readarray -t monitors < <(hyprctl monitors -j | jq -r 'sort_by(.x) | .[].name')
    local i=1
    for mon in "${monitors[@]}"; do
        hyprctl dispatch moveworkspacetomonitor "$i $mon" >/dev/null 2>&1
        hyprctl dispatch focusmonitor "$mon" >/dev/null 2>&1
        hyprctl dispatch workspace "$i" >/dev/null 2>&1
        ((i++))
    done
}

new_workspace() {
    local max
    max=$(hyprctl workspaces -j | jq '[.[].id] | max // 0')
    hyprctl dispatch workspace $((max + 1))
}

cycle_workspace() {
    local dir="$1"
    local mon current
    mon=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
    current=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .activeWorkspace.id')
    readarray -t ids < <(hyprctl workspaces -j | jq -r --arg m "$mon" \
        '[.[] | select(.monitor == $m)] | sort_by(.id) | .[].id')
    local n=${#ids[@]}
    [ "$n" -eq 0 ] && return
    local next="${ids[0]}"
    for i in "${!ids[@]}"; do
        if [ "${ids[$i]}" = "$current" ]; then
            if [ "$dir" = "+1" ]; then
                next="${ids[$(( (i + 1) % n ))]}"
            else
                next="${ids[$(( (i - 1 + n) % n ))]}"
            fi
            break
        fi
    done
    hyprctl dispatch workspace "$next"
}

handle_event() {
    case "$1" in
        monitoradded>>*)
            local mon="${1#monitoradded>>}"
            local max
            max=$(hyprctl workspaces -j | jq '[.[].id] | max // 0')
            local next=$((max + 1))
            sleep 0.5
            hyprctl dispatch moveworkspacetomonitor "$next $mon" >/dev/null 2>&1
            hyprctl dispatch focusmonitor "$mon" >/dev/null 2>&1
            hyprctl dispatch workspace "$next" >/dev/null 2>&1
            ;;
    esac
}

case "$1" in
    daemon)
        init_monitors
        socat - UNIX-CONNECT:"$SOCKET" | while read -r line; do
            handle_event "$line"
        done
        ;;
    new)   new_workspace ;;
    cycle) cycle_workspace "$2" ;;
    init)  init_monitors ;;
esac
