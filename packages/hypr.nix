{pkgs, ...}:
{
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    hyprlock
    hypridle
    hyprpaper
    waybar
    wofi
    swaynotificationcenter
	libnotify
  ];

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
