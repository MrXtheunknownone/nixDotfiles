{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    btop
    tree
    fzf
    ripgrep
  ];
}
