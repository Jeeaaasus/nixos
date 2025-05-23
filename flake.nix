{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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
