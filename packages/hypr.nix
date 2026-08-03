{pkgs, ...}:
{

  # https://wiki.nixos.org/wiki/Hyprland
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    hyprlock
    hypridle
    hyprpaper
    waybar
    wofi
    rofi
    swaynotificationcenter
	  libnotify
    socat
    jq
    grim
    slurp
    swappy
    wl-clipboard
    brightnessctl
  ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  };


  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        user = "tim";
        command = "start-hyprland";
      };
      default_session = initial_session;
    };
  };
}
