{ ... }:
{
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono Nerd Font Mono";
      size = 9;
    };

    settings = {
      disable_ligatures       = "always";
      sync_to_monitor         = false;
      enable_audio_bell       = false;
      window_padding_width    = 5;
      confirm_os_window_close = 0;
      tab_bar_style           = "powerline";
      tab_powerline_style     = "round";
    };

    # Colors are managed at runtime by lcars-theme-switch → ~/.config/kitty/colors.conf
    extraConfig = "include /home/tim/.config/kitty/colors.conf";

    shellIntegration.enableZshIntegration = true;
  };
}
