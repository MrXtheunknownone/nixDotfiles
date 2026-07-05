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
		];
}
			
