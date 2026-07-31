#!/usr/bin/env bash
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# hyprctl dispatch in Lua config mode requires Lua expressions
hl_dispatch() {
    hyprctl dispatch "$1"
}

init_monitors() {
    sleep 0.5  # let Hyprland settle after start/reconnect
    readarray -t monitors < <(hyprctl monitors -j | jq -r 'sort_by(.x) | .[].name')
    local i=1
    for mon in "${monitors[@]}"; do
        hl_dispatch "hl.dsp.workspace.move({ workspace = $i, monitor = '$mon' })"
        hl_dispatch "hl.dsp.focus({ monitor = '$mon' })"
        hl_dispatch "hl.dsp.focus({ workspace = $i })"
        ((i++))
    done
}

new_workspace() {
    local mon current target
    mon=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
    current=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .activeWorkspace.id')

    # Find the lowest-id empty workspace on the current monitor (skip current)
    target=$(hyprctl workspaces -j | jq -r --arg m "$mon" --argjson c "$current" \
        '[.[] | select(.monitor == $m and .windows == 0 and .id != $c)] | sort_by(.id) | if length > 0 then .[0].id else "" end')

    if [ -n "$target" ]; then
        hl_dispatch "hl.dsp.focus({ workspace = $target })"
    else
        # No empty workspace on this monitor — create one (global max+1 is guaranteed unused)
        local max_global
        max_global=$(hyprctl workspaces -j | jq '[.[].id] | max // 0')
        hl_dispatch "hl.dsp.focus({ workspace = $((max_global + 1)) })"
    fi
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
    hl_dispatch "hl.dsp.focus({ workspace = $next })"
}

handle_event() {
    case "${1%%>>*}" in
        monitoradded)
            init_monitors
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
