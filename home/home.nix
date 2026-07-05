{ config, pkgs, lib, ... }: {

  home.username = "tim";
  home.homeDirectory = "/home/tim";

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  # Hyprland
  xdg.configFile."./hypr/hyprland.lua".source = ./hypr/hyprland.lua;
  xdg.configFile."./hypr/hypridle.conf".source = ./hypr/hypridle.conf;
  xdg.configFile."./hypr/hyprlock.conf".source = ./hypr/hyprlock.conf;

  home.file."pictures/wallpapers".source = ./wallpapers;
  services.hyprpaper = {
    enable = true;
    settings = {
      wallpaper = [
        {
          fit_mode = "cover";
          monitor = "eDP-1"; # TODO TL: How to set dynamically?
          path = "${config.home.homeDirectory}/pictures/wallpapers/voyager_orbit.jpg";
        }
      ];
    };
    # package = { };
    # importantPrefixes = { };
  };

  # Kitty
  xdg.configFile."kitty/kitty.conf".source = ./kitty/kitty.conf;

  # Waybar
  xdg.configFile."waybar/config.jsonc".source = ./waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source = ./waybar/style.css;
  xdg.configFile."waybar/colors.css".source = ./waybar/colors.css;

  # Wofi
  xdg.configFile."wofi/config".source = ./wofi/config;
}
