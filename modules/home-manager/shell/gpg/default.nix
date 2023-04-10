{ config, options, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my.options) mkBoolOpt;
  cfg = config.modules.shell.gpg;
in
{
  options.modules.shell.gpg = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      mutableKeys = false;
      mutableTrust = false;
      publicKeys = [
        {
          source = ./pub.key;
          trust = "ultimate";
        }
      ];
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
    };

  };
}
