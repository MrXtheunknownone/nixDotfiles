{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    vim
    neovim
    tmux
  ];

  programs.neovim.defaultEditor = true;
}
