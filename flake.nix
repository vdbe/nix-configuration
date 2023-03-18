{
  description = "A very basic flake";

  inputs =
    {
      # Core dependencies
      #nixpkgs.url = "nixpkgs/nixos-unstable"; # primary nixpkgs
      nixpkgs.url = "nixpkgs/nixos-22.11"; # primary nixpkgs
      nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable"; # for packages on the edge
      utils.url = "github:numtide/flake-utils";

      flake-compat = {
        url = "github:edolstra/flake-compat";
        flake = false;
      };

      deploy-rs = {
        url = "github:serokell/deploy-rs";
        inputs = {
          nixpkgs.follows = "nixpkgs-unstable";
          utils.follows = "utils";
          flake-compat.follows = "flake-compat";
        };
      };

      home-manager = {
        url = "github:nix-community/home-manager";
        inputs = {
          nixpkgs.follows = "nixpkgs";
          utils.follows = "utils";
        };
      };

      devenv = {
        url = "github:cachix/devenv";
        inputs = {
          nixpkgs.follows = "nixpkgs-unstable";
          flake-compat.follows = "flake-compat";
        };
      };

      sops-nix = {
        url = "github:Mic92/sops-nix";
        inputs = {
          nixpkgs.follows = "nixpkgs-unstable";
          nixpkgs-stable.follows = "nixpkgs";
        };
      };

      # Extras
      nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, utils, home-manager, devenv, deploy-rs, ... }:
    let
      inherit (lib.my) mapModules mapModulesRec mapHosts mapUsers genAttrs;


      supportedSystems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      mkPkgs = system: pkgs: extraOverlays: import pkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = extraOverlays ++ (lib.attrValues self.overlays);
      };

      inherit (utils.lib) filterPackages;

      pkgs = forAllSystems (system: mkPkgs system nixpkgs [ ]);
      pkgs' = forAllSystems (system: mkPkgs system nixpkgs-unstable [ ]);

      lib = nixpkgs.lib.extend
        (self: _super: {
          my = import ./lib {
            inherit inputs pkgs;
            lib = self;
          };
        } // home-manager.lib);
    in
    {
      lib = lib.my;

      overlays = {
        default = final: _prev: {
          # NOTE: maybe replace `final.system` with `prev.stdenv.hostPlatform.system`
          unstable = pkgs'.${final.system};
          my = self.packages.${final.system};
        };
      } // mapModules ./overlays import;


      #packages = forAllSystems (system: mapModules ./packages (p: pkgs."${system}".callPackage p { }));
      packages = forAllSystems (system: filterPackages system (mapModules ./packages (p: pkgs."${system}".callPackage p { })));

      devShells = forAllSystems (system: {
        default = let _pkgs = pkgs."${system}"; in
          devenv.lib.mkShell {
            #inherit inputs;
            inputs = { inherit nixpkgs; };
            pkgs = _pkgs;
            modules = [
              {
                packages = with _pkgs; [
                  _pkgs.deploy-rs
                  sops
                ];

                languages.nix.enable = true;

                pre-commit.hooks = {
                  deadnix.enable = true;
                  nixpkgs-fmt.enable = true;
                  statix.enable = true;
                };
              }
            ];
          };
      });

      formatter = forAllSystems (system: pkgs."${system}".nixpkgs-fmt);

      apps = forAllSystems (system:
        {
          default = {
            type = "app";
            program = "${pkgs.${system}.deploy-rs}/bin/deploy";
          };
        });

      modules = mapModulesRec ./modules import;

      nixosConfigurations = mapHosts ./hosts { };
      homeConfigurations = mapUsers ./users { };

      deploy = {
        nodes = {
          nixos01 = {
            hostname = "nixos01.lab.home.arpa";
            sshUser = "user";
            profiles = {
              system = {
                user = "root";
                path = deploy-rs.lib.x86_64-linux.activate.nixos
                  self.nixosConfigurations.nixos01;
              };
              #user = {
              #  user = "user";
              #  path = deploy-rs.lib.x86_64-linux.activate.home-manager
              #    self.homeConfigurations.user;
              #};
            };
          };
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
