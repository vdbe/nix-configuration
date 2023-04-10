{ config, options, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my.options) mkBoolOpt;

  cfg = config.modules.shell.starship;
in
{
  options.modules.shell.starship = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
    };
  };
}

