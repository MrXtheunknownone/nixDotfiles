{
  description = "Private Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    home-manager = {
        url = "github:nix-community/home-manager/release-26.05";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ...}:
    let lib = nixpkgs.lib; in {
      nixosModules.base = import ./modules/base.nix;

      nixosConfigurations = {
        mrnix = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
          ./hosts/mrnix
          self.nixosModules.base
          home-manager.nixosModules.default
          ];
        };
      };
    };
}
