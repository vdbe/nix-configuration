{ options, config, lib, ... }:

let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) nullOr str;

  cfg = config.modules.desktop.browsers;
in
{
  options.modules.desktop.browsers = {
    default = mkOption {
      type = nullOr str;
      default = null;
      description = "Default system browser";
      example = "firefox";
    };
  };

  config = mkIf (cfg.default != null) { };
}
