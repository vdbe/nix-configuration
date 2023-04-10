{ config, options, lib, pkgs, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my.options) mkBoolOpt;

  cfg = config.modules.shell.bitwarden-cli;
in
{
  options.modules.shell.bitwarden-cli = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ unstable.bitwarden-cli ];
  };
}

