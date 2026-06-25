{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
       url = "github:nix-community/home-manager";
       inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";

      commonModules = [
        inputs.home-manager.nixosModules.default
        inputs.lanzaboote.nixosModules.lanzaboote

        ({ pkgs, lib, ... }: {
          # Fakking electron
          nixpkgs.config.permittedInsecurePackages = [
            "electron-39.8.10"
          ];

#          home-manager = {
#            useGlobalPkgs = true;
#            useUserPackages = true;
#          };
          
          environment.systemPackages = [
            pkgs.sbctl
          ];

          boot.loader.systemd-boot.enable = lib.mkForce false;

          boot.lanzaboote = {
            enable = true;
            pkiBundle = "/var/lib/sbctl";
          };
        })
      ];
    in
    {
      nixosConfigurations.skala = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = commonModules
        ++ [
          ./hosts/skala/configuration.nix
        ];
      };
    };
}
