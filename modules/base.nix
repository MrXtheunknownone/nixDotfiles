{ config, lib, pkgs, ... }:
{
  imports = [
    ../packages/browser.nix
    ../packages/creativity.nix
    ../packages/development.nix
    ../packages/editor.nix
    ../packages/fonts.nix
    ../packages/git.nix
    ../packages/hypr.nix
    ../packages/media.nix
    ../packages/security.nix
    ../packages/shell.nix
    ../packages/social.nix
    ../packages/sound.nix
    ../packages/utils.nix
  ];

  home-manager.users.tim = import ../home/home.nix;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  services.libinput.enable = true;

  users.users.tim = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Amsterdam";

  system.stateVersion = "26.05";
}
