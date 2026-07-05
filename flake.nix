{
  description = "Private Flake"

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05"
  };

  outputs = { self, nixpkgs, ...}: {
    let lib = nixpkgs.lib; in {
      nixosConfigurations = {
        mrnix = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./configuration.nix ];
        };
      };
    };
  };
}
