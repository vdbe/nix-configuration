{ config, lib, ... }:

with lib;
with lib.my;
let
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
      };
    };

    #system.stateVersion = vars.stateVersion;
  };
}

