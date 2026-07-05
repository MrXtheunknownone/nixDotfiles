{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    discord
    whatsapp-electron
    thunderbird
    zoom
  ];

  # services.mattermost.enable = true;
}
