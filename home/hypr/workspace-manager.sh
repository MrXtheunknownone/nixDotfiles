#!/usr/bin/env bash
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# hyprctl dispatch in Lua config mode requires Lua expressions
hl_dispatch() {
    hyprctl dispatch "$1"
}

init_monitors() {
    sleep 1  # let Hyprland settle after start/reconnect
    readarray -t monitors < <(hyprctl monitors -j | jq -r 'sort_by(.x) | .[].name')
    local i=1
    for mon in "${monitors[@]}"; do
        hl_dispatch "hl.dsp.workspace.move({ workspace = $i, monitor = '$mon' })"
        hl_dispatch "hl.dsp.focus({ monitor = '$mon' })"
        hl_dispatch "hl.dsp.focus({ workspace = $i })"
        ((i++))
    done
}

save_state() {
    local state_file="/tmp/hypr-ws-monitor-${HYPRLAND_INSTANCE_SIGNATURE}.state"
    local monitors_json
    monitors_json=$(hyprctl monitors -j | jq 'sort_by(.x) | [.[].name]')
    hyprctl workspaces -j | jq -r \
        --argjson mons "$monitors_json" \
        '.[] | . as $ws | select(($mons | index($ws.monitor)) != null) |
         "\($ws.id) \($mons | index($ws.monitor))"' \
        > "$state_file"
}

restore_state() {
    local state_file="/tmp/hypr-ws-monitor-${HYPRLAND_INSTANCE_SIGNATURE}.state"
    [ -f "$state_file" ] || return 0
    readarray -t monitors < <(hyprctl monitors -j | jq -r 'sort_by(.x) | .[].name')
    local num_monitors=${#monitors[@]}
    [ "$num_monitors" -eq 0 ] && return 0
    while read -r ws_id mon_idx; do
        if [ "$mon_idx" -ge "$num_monitors" ]; then
            mon_idx=$(( num_monitors - 1 ))
        fi
        hl_dispatch "hl.dsp.workspace.move({ workspace = $ws_id, monitor = '${monitors[$mon_idx]}' })"
    done < "$state_file"
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
            restore_state
            save_state
            ;;
        createworkspace|destroyworkspace)
            save_state
            ;;
    esac
}

case "$1" in
    daemon)
        init_monitors
        save_state
        socat - UNIX-CONNECT:"$SOCKET" | while read -r line; do
            handle_event "$line"
        done
        ;;
    new)   new_workspace ;;
    cycle) cycle_workspace "$2" ;;
    init)  init_monitors ;;
esac
