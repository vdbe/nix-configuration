{ config, options, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;

  cfg = config.modules.shell.bash;
in
{
  options.modules.shell.bash = {
    enable = mkBoolOpt false;
  };


  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
    };
  };
}

