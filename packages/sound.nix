{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    wiremix
  ];
}
