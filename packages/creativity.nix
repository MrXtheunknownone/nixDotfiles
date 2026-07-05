{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    gimp
    rawtherapee
  ];
}
