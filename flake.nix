{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    pkgs-20250216.url = "github:NixOS/nixpkgs?rev=2ff53fe64443980e139eaa286017f53f88336dd0";
    pkgs-clamav-patch = {
      url = "https://github.com/NixOS/nixpkgs/pull/375635.patch";
      flake = false;
    };
  };

  outputs = inputs@{ self, ... }:
    let
      vars = import ./variables.nix;
    in

    {
      nixosConfigurations = {
        "${vars.hostname}" = inputs.nixpkgs.lib.nixosSystem {
          inherit (vars.system);
          specialArgs = {
            inherit inputs;
            inherit vars;
          };
          modules = [
            {
              nix.settings.experimental-features = [ "nix-command" "flakes" ];
            }

            ./configuration.nix

            inputs.home-manager.nixosModules.home-manager {
              home-manager.users.${vars.username} = import ./home.nix;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                inherit vars;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        };
      };
    };
}
