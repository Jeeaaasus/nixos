{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    # nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    "2025-11-23".url = "github:NixOS/nixpkgs?rev=ee09932cedcef15aaf476f9343d1dea2cb77e261";
    "2025-04-05".url = "github:NixOS/nixpkgs?rev=250b695f41e0e2f5afbf15c6b12480de1fe0001b";
  };

  outputs =
    { self, ... }@inputs:
    let
      vars = import ./variables.nix;
    in

    {
      nixosConfigurations.${vars.hostname} = inputs.nixpkgs.lib.nixosSystem {
        system = vars.system;
        modules = [
          {
            nixpkgs = {
              config.allowUnfree = true;
            };
            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];
          }

          ./configuration.nix

          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.users.${vars.username} = import ./home.nix;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              inherit vars;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];

        specialArgs = {
          inherit inputs vars;
        };
      };
    };
}
