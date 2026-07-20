{ config, pkgs, lib, ... }: {

  home.username = "tim";
  home.homeDirectory = "/home/tim";

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.nordzy-cursor-theme;
    name = "Nordzy-hyprcursors";
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
  xdg.configFile."waybar/launch.sh".source = ./waybar/launch.sh;

  # Wofi
  xdg.configFile."wofi/config".source = ./wofi/config;
  xdg.configFile."wofi/style.css".source = ./wofi/style.css;

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
