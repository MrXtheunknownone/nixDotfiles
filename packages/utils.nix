{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    wl-clipboard
    wget
    btop
    tree
    fzf
    ripgrep
    ncdu
  ];
}
