{ config, lib, ... }:

let
  inherit (lib) mkIf lists;
  inherit (lib.my) mkBoolOpt;
  cfg = config.modules.nix;
in
{
  options.modules.nix = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    nix = {
      extraOptions = ''
        experimental-features = nix-command flakes
        min-free = ${toString (100 * 1024 * 1024)}
        max-free = ${toString (1024 * 1024 * 1024)}
      '';

      gc = {
        automatic = true;
        persistent = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

      settings = {
        trusted-users = [ "root" "@wheel" ];
        auto-optimise-store = true;

        trusted-substituters = [
          "https://cache.nixos.org?priority=10"
          "https://nix-community.cachix.org"
        ]
        ++ lists.optional config.modules.desktop.hyprland.enable "https://hyprland.cachix.org";

        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ]
        ++ lists.optional config.modules.desktop.hyprland.enable "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";
      };


    };

    #system.stateVersion = vars.stateVersion;
  };
}

