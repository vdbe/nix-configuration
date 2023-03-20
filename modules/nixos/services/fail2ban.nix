{ config, options, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;

  cfg = config.modules.services.fail2ban;
in
{
  options.modules.services.fail2ban = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
      #ignoreIP = [ "127.0.0.1/16" "192.168.1.0/24" ];
      banaction-allports = "iptables-allports";
      bantime-increment = {
        enable = true;
        maxtime = "168h";
        factor = "4";
      };
      jails.DEFAULT = ''
        blocktype = DROP
        bantime = 1h
        findtime = 1h
      '';
    };

  };
}
