{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    netflix
    swayimg
    grim
    slurp
    swappy
    mpv
    wf-recorder
  ];
}
