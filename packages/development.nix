{ pkgs, ... }: {
  virtualisation.docker = {
    enable = true;
  };

  # environment.systemPackages = [
  #   inputs.compose2nix.packages.x86_64-linux.default
  # ];
}
