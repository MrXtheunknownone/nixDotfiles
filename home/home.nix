{ config, pkgs, lib, ... }:
let
  sunity-cursors = pkgs.callPackage ../packages/sunity-cursors.nix { };
in {
  imports = [ ../packages/security.nix ];

  xdg.autostart.enable = true;

  home.username = "tim";
  home.homeDirectory = "/home/tim";

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = sunity-cursors;
    name = "Sunity-cursors";
    size = 16;
  };

  gtk = {
    enable = true;

    theme = {
      package = pkgs.nordic;
      name = "Nordic";
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "JetBrains Mono";
      size = 11;
    };
  };

  # Gnome apps
  # qt = {
  #   enable = true;
  #   platformTheme = "gnome";
  #   style = "adwaita-dark";
  # };

  # Hyprland
  xdg.configFile."./hypr/hyprland.lua".source = ./hypr/hyprland.lua;
  xdg.configFile."./hypr/hypridle.conf".source = ./hypr/hypridle.conf;
  xdg.configFile."./hypr/hyprlock.conf".source = ./hypr/hyprlock.conf;
  xdg.configFile."./hypr/workspace-manager.sh" = {
    source = ./hypr/workspace-manager.sh;
    executable = true;
  };
  xdg.configFile."./hypr/wallpaper-manager.sh" = {
    source = ./hypr/wallpaper-manager.sh;
    executable = true;
  };

  home.file."pictures/wallpapers".source = ./wallpapers;
  services.hyprpaper = {
    enable = true;
    settings = {
      wallpaper = [
        {
          fit_mode = "cover";
          monitor = "*";
          path = "${config.home.homeDirectory}/pictures/wallpapers/voyager_orbit.jpg";
        }
        {
          fit_mode = "cover";
          monitor = "desc:Iiyama North America PL4580DQ 1222642810142";
          path = "${config.home.homeDirectory}/pictures/wallpapers/voyager_engineering_panel.jpg";
        }
      ];
    };
    # package = { };
    # importantPrefixes = { };
  };

  # Swaync (notification center — enables the MPRIS media-player widget)
  xdg.configFile."swaync/config.json".source = ./swaync/config.json;
  xdg.configFile."swaync/style.css".source = ./swaync/style.css;

  # Kitty
  xdg.configFile."kitty/kitty.conf".source = ./kitty/kitty.conf;

  # Waybar
  xdg.configFile."waybar/config.jsonc".source = ./waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source = ./waybar/style.css;
  xdg.configFile."waybar/colors.css".source = ./waybar/colors.css;
  xdg.configFile."waybar/launch.sh".source = ./waybar/launch.sh;

  # Wofi
  xdg.configFile."wofi/config".source = ./wofi/config;
  xdg.configFile."wofi/style.css".source = ./wofi/style.css;

  # Rofi — LCARS launcher (SUPER+Space)
  # Minimal config.rasi: just point at the theme; all configuration lives in lcars.rasi.
  xdg.configFile."rofi/config.rasi".text = ''
    @theme "/home/tim/.config/rofi/lcars.rasi"
  '';
  xdg.configFile."rofi/lcars.rasi".source = ./rofi/lcars.rasi;
  xdg.configFile."rofi/lcars-launch.sh" = {
    source = ./rofi/lcars-launch.sh;
    executable = true;
  };

  # Vivaldi: shadow the package's own launcher entry with one that forces
  # native Wayland (Ozone) instead of XWayland under Hyprland.
  # xdg.desktopEntries.vivaldi-stable = {
  #   name = "Vivaldi";
  #   genericName = "Web Browser";
  #   exec = "vivaldi-stable --ozone-platform=wayland --enable-features=WaylandWindowDecorations %U";
  #   icon = "vivaldi";
  #   terminal = false;
  #   type = "Application";
  #   categories = [ "Network" "WebBrowser" ];
  #   mimeType = [
  #     "text/html"
  #     "text/xml"
  #     "application/xhtml+xml"
  #     "x-scheme-handler/http"
  #     "x-scheme-handler/https"
  #   ];
  #   startupNotify = true;
  # };

  # Seed the Vivaldi profile with theme/settings/extensions from this repo.
  # Uses an activation script (not xdg.configFile) because a browser profile
  # needs continuous write access, not a read-only Nix-store symlink.
  # --ignore-existing makes this fill in only what's missing on a fresh
  # profile; it never overwrites live browser state on later switches.
  # home.activation.seedVivaldiProfile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #   $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/.config/vivaldi"
  #   $DRY_RUN_CMD ${pkgs.rsync}/bin/rsync -a --ignore-existing "${./vivaldi}/" "${config.home.homeDirectory}/.config/vivaldi/"
  # '';
}
