{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";
    pkgs-20260414.url = "github:NixOS/nixpkgs?rev=4bd9165a9165d7b5e33ae57f3eecbcb28fb231c9";
    pkgs-20260515.url = "github:NixOS/nixpkgs?rev=d233902339c02a9c334e7e593de68855ad26c4cb";
  };

  outputs = { self, ... }@inputs:
    let
      vars = import ./variables.nix;
      system = vars.system;

      mkPkgs = nixpkgsInput: import nixpkgsInput {
        inherit system;
        config = {
          allowUnfree = true;

          permittedInsecurePackages = [];
        };

        overlays = [];
      };

      pkgs = mkPkgs inputs.nixpkgs;
      pkgs_stable = mkPkgs inputs.pkgs-stable;
      pkgs_20260414 = mkPkgs inputs.pkgs-20260414;
      pkgs_20260515 = mkPkgs inputs.pkgs-20260515;
    in

    {
      nixosConfigurations.${vars.hostname} = inputs.nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        specialArgs = {
          inherit inputs vars pkgs_stable pkgs_20260414 pkgs_20260515;
        };

        modules = [
          {
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
              inherit inputs vars pkgs_stable pkgs_20260414 pkgs_20260515;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
    };
}
