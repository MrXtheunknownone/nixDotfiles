{ config, pkgs, lib, ... }:
let
  sunity-cursors = pkgs.callPackage ../packages/sunity-cursors.nix { };

  # ── LCARS theme system ────────────────────────────────────────────────────
  picard = import ./themes/picard.nix;
  mrx    = import ./themes/mrx.nix;

  # Convert a palette attrset → @define-color CSS block (waybar + swaync)
  mkCss = p: lib.concatStringsSep "\n"
    (lib.mapAttrsToList (n: v: "@define-color ${n} ${v};") p);

  # Convert a palette attrset → RASI * { } color block (rofi)
  mkRasi = p: "* {\n" +
    lib.concatStringsSep "\n"
      (lib.mapAttrsToList (n: v: "    ${n}: ${v};") p) +
    "\n}";

  # Convert a palette attrset → shell-sourceable env file (ImageMagick etc.)
  mkEnv = p: lib.concatStringsSep "\n"
    (lib.mapAttrsToList (n: v: "LCARS_${n}='${v}'") p);

  # Generate a kitty colors.conf from a flat attrset of key = "#hex" pairs.
  mkKitty = colors: lib.concatStringsSep "\n"
    (lib.mapAttrsToList (n: v: "${n} ${v}") colors);

  picardKitty = {
    background_opacity    = "0.85";
    background            = "#000000"; foreground           = "#d2d5df";
    cursor                = "#41c4f7"; cursor_text_color    = "#000000";
    selection_background  = "#1c3c55"; selection_foreground = "#f3f4f7";
    url_color             = "#37a6d1";
    active_tab_foreground   = "#000000"; active_tab_background   = "#41c4f7";
    inactive_tab_foreground = "#6d748c"; inactive_tab_background = "#2f3749";
    tab_bar_background    = "#000000";
    active_border_color   = "#41c4f7"; inactive_border_color = "#2f3749";
    color0  = "#000000"; color8  = "#2f3749";
    color1  = "#e7442a"; color9  = "#e7442a";
    color2  = "#4daa6e"; color10 = "#4daa6e";
    color3  = "#ff977b"; color11 = "#ff977b";
    color4  = "#37a6d1"; color12 = "#41c4f7";
    color5  = "#ff6753"; color13 = "#ff6753";
    color6  = "#2a7193"; color14 = "#41c4f7";
    color7  = "#d2d5df"; color15 = "#f3f4f7";
  };

  mrxKitty = {
    background_opacity    = "0.95";
    background            = "#232a2e"; foreground           = "#d3c6aa";
    cursor                = "#83c092"; cursor_text_color    = "#1c2326";
    selection_background  = "#2d353b"; selection_foreground = "#cdd6f4";
    url_color             = "#a7c080";
    active_tab_foreground   = "#1c2326"; active_tab_background   = "#a7c080";
    inactive_tab_foreground = "#7a8478"; inactive_tab_background = "#3d484d";
    tab_bar_background    = "#232a2e";
    active_border_color   = "#83c092"; inactive_border_color = "#3d484d";
    color0  = "#232a2e"; color8  = "#3d484d";
    color1  = "#e67e80"; color9  = "#e67e80";
    color2  = "#a7c080"; color10 = "#a7c080";
    color3  = "#dbbc7f"; color11 = "#dbbc7f";
    color4  = "#7fbbb3"; color12 = "#7fbbb3";
    color5  = "#d699b6"; color13 = "#d699b6";
    color6  = "#83c092"; color14 = "#83c092";
    color7  = "#d3c6aa"; color15 = "#cdd6f4";
  };

  lcarsThemeSwitch = pkgs.writeShellScript "lcars-theme-switch" ''
    THEME="''${1:-picard}"
    THEMES_DIR="$HOME/.config/lcars-themes"

    echo "$THEME" > "$HOME/.config/lcars-current-theme"

    # install -m 644 removes the destination before copying, so read-only
    # files inherited from the Nix store don't block subsequent switches.
    install -m 644 "$THEMES_DIR/$THEME/colors.css"        "$HOME/.config/waybar/colors.css"
    install -m 644 "$THEMES_DIR/$THEME/colors.css"        "$HOME/.config/swaync/colors.css"
    install -m 644 "$THEMES_DIR/$THEME/colors.rasi"       "$HOME/.config/rofi/colors.rasi"
    install -m 644 "$THEMES_DIR/$THEME/active.env"        "$THEMES_DIR/active.env"
    install -m 644 "$THEMES_DIR/$THEME/kitty-colors.conf" "$HOME/.config/kitty/colors.conf"

    # Reload in place — no kill/restart, no new windows, no focus stealing.
    pkill -SIGUSR2 waybar 2>/dev/null || true
    swaync-client --reload-css 2>/dev/null || true
    pkill -SIGUSR1 kitty 2>/dev/null || true

    notify-send -a "LCARS" "Theme: $THEME" "Applied."
  '';

  lcarsThemeMenu = pkgs.writeShellScript "lcars-theme-menu" ''
    case "$ROFI_RETV" in
      0)
        echo "LCARS MRX"
        echo "LCARS Picard"
        ;;
      1)
        case "$1" in
          "LCARS MRX")    nohup "$HOME/.local/bin/lcars-theme-switch" mrx    >/dev/null 2>&1 & ;;
          "LCARS Picard") nohup "$HOME/.local/bin/lcars-theme-switch" picard >/dev/null 2>&1 & ;;
        esac
        pkill -x rofi
        ;;
    esac
  '';
in {
  imports = [ ../packages/security.nix ./zsh.nix ./kitty.nix ];

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

  # Kitty config is managed by programs.kitty in ./kitty.nix

  # Waybar (colors.css is NOT managed here — lcars-theme-switch owns it at runtime)
  xdg.configFile."waybar/config.jsonc".source = ./waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source = ./waybar/style.css;
  xdg.configFile."waybar/launch.sh".source = ./waybar/launch.sh;

  # Wofi
  xdg.configFile."wofi/config".source = ./wofi/config;
  xdg.configFile."wofi/style.css".source = ./wofi/style.css;

  # ── LCARS theme files (read-only, Nix store; switch script copies to active locations) ──
  xdg.configFile."lcars-themes/picard/colors.css".text        = mkCss picard;
  xdg.configFile."lcars-themes/picard/colors.rasi".text       = mkRasi picard;
  xdg.configFile."lcars-themes/picard/active.env".text        = mkEnv picard;
  xdg.configFile."lcars-themes/picard/kitty-colors.conf".text = mkKitty picardKitty;
  xdg.configFile."lcars-themes/mrx/colors.css".text           = mkCss mrx;
  xdg.configFile."lcars-themes/mrx/colors.rasi".text          = mkRasi mrx;
  xdg.configFile."lcars-themes/mrx/active.env".text           = mkEnv mrx;
  xdg.configFile."lcars-themes/mrx/kitty-colors.conf".text    = mkKitty mrxKitty;

  # ── Theme switcher scripts ────────────────────────────────────────────────
  home.file.".local/bin/lcars-theme-switch" = {
    source      = lcarsThemeSwitch;
    executable  = true;
  };
  home.file.".local/bin/lcars-theme-menu" = {
    source      = lcarsThemeMenu;
    executable  = true;
  };

  # ── Apply persisted theme after every home-manager switch ─────────────────
  # Uses the switch script which reloads waybar/swaync in place (SIGUSR2 / swaync-client).
  home.activation.applyTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    THEME=$(cat $HOME/.config/lcars-current-theme 2>/dev/null || echo "picard")
    $DRY_RUN_CMD $HOME/.local/bin/lcars-theme-switch "$THEME" 2>/dev/null || true
  '';

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
  xdg.configFile."rofi/theme-menu.sh" = {
    source = ./rofi/theme-menu.sh;
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
