#!/usr/bin/env bash
# Rofi script-mode handler for LCARS theme switching.
# ROFI_RETV=0 → listing call; ROFI_RETV=1 → selection made.

CURRENT=$(cat "$HOME/.config/lcars-current-theme" 2>/dev/null || echo "picard")

case "$ROFI_RETV" in
  0)
    echo "LCARS MRX"
    echo "LCARS Picard"
    ;;
  1)
    case "$1" in
      "LCARS MRX")    "$HOME/.local/bin/lcars-theme-switch" mrx    ;;
      "LCARS Picard") "$HOME/.local/bin/lcars-theme-switch" picard ;;
    esac
    ;;
esac
