{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    vivaldi
    qutebrowser
  ];

  # Chromium/Electron apps default to XWayland unless told otherwise; this makes
  # Vivaldi (and other Ozone-aware apps) run natively under Hyprland.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
