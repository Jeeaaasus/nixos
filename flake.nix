{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    # nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self,... }@inputs:
    let
      vars = import ./variables.nix;
      system = vars.system;

      mkPkgs = nixpkgsInput: import nixpkgsInput {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [
        ];
      };

      pkgs_stable = mkPkgs inputs.pkgs-stable;
    in

    {
      nixosConfigurations.${vars.hostname} = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs vars pkgs_stable;
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
              inherit inputs vars pkgs_stable;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
    };
}
