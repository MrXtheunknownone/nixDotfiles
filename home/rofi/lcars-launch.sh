#!/usr/bin/env bash
# LCARS Rofi launcher — minimal header + footer, no stats overlay.
# Ctrl+J / Ctrl+K switch modes in-place (kb-mode-next / kb-mode-prev).

BOLD=$(fc-match --format="%{file}" "JetBrainsMono Nerd Font Mono:style=Bold" 2>/dev/null)
[ -z "$BOLD" ] && BOLD="/nix/store/k6xsvmzdgx19jvxnxjlb2lx0zlibv85i-nerd-fonts-jetbrains-mono-3.4.0+2.304/share/fonts/truetype/NerdFonts/JetBrainsMono/JetBrainsMonoNerdFontMono-Bold.ttf"

# Load active theme colors (set by lcars-theme-switch); fall back to Picard defaults.
# shellcheck source=/dev/null
source "$HOME/.config/lcars-themes/active.env" 2>/dev/null || true
FRAME_COLOR="${LCARS_term:-#e7442a}"
FRAME_INK="${LCARS_ink:-#06080c}"

# PNG at 2× logical (1360×884 = 680×442×2) for HiDPI sharpness.
# Header: y=0..87  (44px × 2) — top-left corner rounded only
# Footer: y=804..883 (40px × 2 from bottom) — bottom-left corner rounded only
magick -size "1360x884" xc:none \
  \
  -fill "$FRAME_COLOR" -draw "roundrectangle 0,0 1359,87 40,40" \
  -fill "$FRAME_COLOR" -draw "rectangle 36,0 1359,87" \
  -fill "$FRAME_COLOR" -draw "rectangle 0,44 1359,87" \
  -font "$BOLD" -pointsize 16 -fill "$FRAME_INK" \
  -annotate +18+74 "LCARS" \
  \
  -fill "$FRAME_COLOR" -draw "roundrectangle 0,804 1359,883 40,40" \
  -fill "$FRAME_COLOR" -draw "rectangle 36,804 1359,883" \
  -fill "$FRAME_COLOR" -draw "rectangle 0,804 1359,844" \
  \
  /tmp/lcars-frame-live.png

exec rofi -show "${1:-drun}" -theme /home/tim/.config/rofi/lcars.rasi
