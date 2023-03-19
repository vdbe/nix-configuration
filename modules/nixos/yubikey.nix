{ options, config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;

  cfg = config.modules.yubikey;
in
{
  options.modules.yubikey = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.pcscd.enable = true;
  };
}
