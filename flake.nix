{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # dream2nix.url = "github:nix-community/dream2nix";
    pkgs-20250317.url = "github:NixOS/nixpkgs?rev=e3e32b642a31e6714ec1b712de8c91a3352ce7e1";
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

      # devShells.default = inputs.nixpkgs.mkShell {
      #   buildInputs = [
      #     inputs.dream2nix.packages.${vars.system}.default
      #   ];
      # };
    };
}
