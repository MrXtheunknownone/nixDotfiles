{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    wl-clipboard
    wget
    btop
    tree
    unzip
    fzf
    ripgrep
    ncdu
  ];
}
