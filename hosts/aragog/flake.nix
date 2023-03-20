{
  description = "A very basic flake";

  inputs =
    {
      #nixpkgs.url = "nixpkgs/nixos-unstable"; # primary nixpkgs
      nixpkgs.url = "nixpkgs/nixos-22.11"; # primary nixpkgs
      nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable"; # for packages on the edge

      nix-configuration = {
        url = "../../";
        inputs = {
          nixpkgs.follows = "nixpkgs";
          nixpkgs-unstable.follows = "nixpkgs-unstable";
        };
      };
    };

  outputs = { self, nix-configuration, ... }:
    let
      inherit (nix-configuration.inputs) deploy-rs;
    in
    {
      inherit (nix-configuration) apps;

      inherit (nix-configuration) nixosConfigurations;
      inherit (nix-configuration) homeConfigurations;

      deploy = {
        nodes = {
          aragog = {
            hostname = "192.168.0.216";
            sshUser = "user";
            profiles = {
              system = {
                user = "root";
                path = deploy-rs.lib.x86_64-linux.activate.nixos
                  self.nixosConfigurations.aragog;
              };
              #user = {
              #  user = "user";
              #  path = deploy-rs.lib.x86_64-linux.activate.home-manager
              #    self.homeConfigurations.user;
              #};
            };
          };
        };
        #magicRollback = false;
        #autoRollback = false;
      };


    };
}
