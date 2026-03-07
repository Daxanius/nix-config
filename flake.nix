{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
       url = "github:nix-community/home-manager";
       inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    # TODO: make hostname dynamic depending on the device building the nix configuration
    nixosConfigurations.skala = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;}; # Take flake input and pass into parameters of every module
      modules = [
        ./configuration.nix
        inputs.home-manager.nixosModules.default
      ];
    };
  };
}
