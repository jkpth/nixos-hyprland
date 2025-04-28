{
  description = "jake's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.virtualbox-vm = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/virtualbox-vm/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.users.jkpth = import ./hosts/virtualbox-vm/home.nix;
          }
        ];
      };
    };
}
