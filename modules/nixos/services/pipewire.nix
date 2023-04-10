{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my.options) mkBoolOpt;

  cfg = config.modules.services.pipewire;
in
{
  options.modules.services.pipewire = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}

