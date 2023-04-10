{
  description = "A very basic flake";

  inputs =
    {
      #nixpkgs.url = "nixpkgs/nixos-unstable"; # primary nixpkgs
      #nixpkgs.url = "nixpkgs/nixos-22.11"; # primary nixpkgs
      #nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable"; # for packages on the edge

      nix-configuration = {
        url = "../../";
        #inputs = {
        #  nixpkgs.follows = "nixpkgs";
        #  nixpkgs-unstable.follows = "nixpkgs-unstable";
        #};
      };
    };

  outputs = { self, nix-configuration, ... }:
    let
      inherit (nix-configuration.inputs) deploy-rs;
    in
    {
      inherit (nix-configuration) apps formatter;

      nixosConfigurations = {
        inherit (nix-configuration.nixosConfigurations) aragog;
      };

      deploy = {
        nodes = {
          aragog = {
            hostname = "aragog";
            sshUser = "user";
            profiles = {
              system = {
                user = "root";
                path = deploy-rs.lib.x86_64-linux.activate.nixos
                  self.nixosConfigurations.aragog;
              };
            };
          };
        };
        #magicRollback = false;
        #autoRollback = false;
      };
    };

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org?priority=10"
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"

      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="

      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };
}
