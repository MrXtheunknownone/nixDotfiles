{ pkgs, ... }:
let
  theme = pkgs.stdenv.mkDerivation {
    name = "mr-nix-plymouth-theme";
    src = ../home/plymouth/mr-nix;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/plymouth/themes/mr-nix
      cp -r . $out/share/plymouth/themes/mr-nix/
    '';
  };
in {
  boot.plymouth = {
    enable = true;
    theme = "mr-nix";
    themePackages = [ theme ];
  };
}
