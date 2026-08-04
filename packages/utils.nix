{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    wl-clipboard
    wayscriber
    wget
    btop
    tree
    unzip
    fzf
    ripgrep
    ncdu
  ];
}
