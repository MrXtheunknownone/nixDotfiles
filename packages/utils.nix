{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    wl-clipboard
    btop
    tree
    fzf
    ripgrep
  ];
}
