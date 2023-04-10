{
  description = "A very basic flake";

  inputs = {
    # Core dependencies
    #nixpkgs.url = "nixpkgs/nixos-unstable"; # primary nixpkgs
    nixpkgs.url = "nixpkgs/nixos-22.11"; # primary nixpkgs
    nixpkgs-unstable.url =
      "nixpkgs/nixpkgs-unstable"; # for packages on the edge
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
      url = "github:cachix/devenv?ref=latest";
      inputs = {
        #nixpkgs.follows = "nixpkgs-unstable";
        #flake-compat.follows = "flake-compat";
      };
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };

    hyprland = {
      url = "github:hyprwm/Hyprland?ref=v0.23.0beta";
      #inputs.nixpkgs.follows = "nixpkgs";
      #inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Extras
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , devenv
    , deploy-rs
    , ...
    }:
    let
      inherit (nixpkgs.lib) attrValues genAttrs;
      inherit (lib.my.nixos) mapHosts;

      supportedSystems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = genAttrs supportedSystems;

      mkPkgs = system: pkgs: extraOverlays: import pkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = extraOverlays ++ (attrValues self.overlays);
      };

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
      inherit inputs;

      lib = lib.my;

      packages = forAllSystems (system: import ./packages { inherit lib; pkgs = pkgs."${system}"; });

      formatter = forAllSystems (system: pkgs."${system}".nixpkgs-fmt);

      #nixosConfigurations = mapHosts ./hosts { };
      nixosConfigurations = import ./hosts { inherit lib pkgs inputs; };

      modules = { };

      overlays = {
        default = final: _prev: {
          # NOTE: maybe replace `final.system` with `prev.stdenv.hostPlatform.system`
          unstable = pkgs'.${final.system};
          my = self.packages.${final.system};
        };
      };
    };

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org?priority=10"
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
      "https://cache.garnix.io"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
    #extra-trusted-public-keys = [ "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" ];
    #extra-substituters = [ "https://devenv.cachix.org" ];
  };

  #nixConfig = {
  #  extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
  #  extra-substituters = "https://devenv.cachix.org";
  #};
}
