{ ... }:
{
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono Nerd Font Mono";
    };

    settings = {
      disable_ligatures     = "always";
      sync_to_monitor       = false;
      enable_audio_bell     = false;
      window_padding_width  = 5;
      confirm_os_window_close = 0;

      background_opacity    = "0.85";

      # LCARS Picard base colors
      background           = "#000000";
      foreground           = "#d2d5df";
      cursor               = "#41c4f7";
      cursor_text_color    = "#000000";
      selection_background = "#1c3c55";
      selection_foreground = "#f3f4f7";
      url_color            = "#37a6d1";

      # ANSI 16-color palette
      color0  = "#000000";  color8  = "#2f3749";
      color1  = "#e7442a";  color9  = "#e7442a";
      color2  = "#4daa6e";  color10 = "#4daa6e";
      color3  = "#ff977b";  color11 = "#ff977b";
      color4  = "#37a6d1";  color12 = "#41c4f7";
      color5  = "#ff6753";  color13 = "#ff6753";
      color6  = "#2a7193";  color14 = "#41c4f7";
      color7  = "#d2d5df";  color15 = "#f3f4f7";

      # Tab bar
      tab_bar_style           = "powerline";
      tab_powerline_style     = "round";
      active_tab_foreground   = "#000000";
      active_tab_background   = "#41c4f7";
      inactive_tab_foreground = "#6d748c";
      inactive_tab_background = "#2f3749";
      tab_bar_background      = "#000000";

      # Window borders
      active_border_color   = "#41c4f7";
      inactive_border_color = "#2f3749";
    };

    shellIntegration.enableZshIntegration = true;
  };
}
