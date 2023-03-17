{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;
  cfg = config.modules.services.ssh;
in
{
  options.modules.services.ssh = {
    enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      openFirewall = true;
      # stateVersion: 23.05
      #settings = {
      #  PermitRootLogin = "no";
      #  PasswordAuthentication = true;
      #};
      permitRootLogin = "no";
      passwordAuthentication = true;
      startWhenNeeded = true;
      extraConfig = ''
        StreamLocalBindUnlink yes
      '';
      #ports = [ 9999 ];
    };
  };
}

