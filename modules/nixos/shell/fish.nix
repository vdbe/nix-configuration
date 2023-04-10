{ config, options, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my.options) mkBoolOpt;

  cfg = config.modules.shell.fish;
in
{
  options.modules.shell.fish = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
    };
  };
}

