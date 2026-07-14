{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    netflix
    swayimg
  ];
}
