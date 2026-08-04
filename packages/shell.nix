{ pkgs, ... }:
{
  users.users.tim.shell = pkgs.zsh;

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
    };
    foot = {
      enable = true;
    };
  };
}
