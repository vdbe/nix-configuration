{ config, options, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my.options) mkBoolOpt;

  cfg = config.modules.shell.direnv;
in
{
  options.modules.shell.direnv = {
    enable = mkBoolOpt false;
    nix-direnv = {
      enable = mkBoolOpt config.modules.nix.enable;
    };
  };

  config = mkIf cfg.enable
    {
      programs.direnv = {
        enable = true;

        inherit (cfg) nix-direnv;
      };
    };
}

