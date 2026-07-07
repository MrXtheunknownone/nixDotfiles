{ ... }:
{
  networking.hostName = "mrnix";

  imports = [
    ./hardware-configuration.nix
  ];
}
