{ config, options, lib, ... }:

let
  inherit (lib) mkIf mkOption types optionalAttrs literalExpression;
  inherit (lib.my.options) mkBoolOpt;

  cfg = config.modules.shell.bat;

  shellAliases = { } // optionalAttrs cfg.enableAliases {
    cat = "bat -p";
  };
in
{

  options.modules.shell.bat = {
    enable = mkBoolOpt false;

    enableAliases = mkOption {
      default = true;
      description = "recommended bat aliases (cat)";
      type = types.bool;
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      example = literalExpression
        "with pkgs.bat-extras; [ batdiff batman batgrep batwatch ];";
      description = ''
        Additional bat packages to install.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs = {
      bat = {
        inherit (cfg) enable extraPackages;
      };
    };
    home.shellAliases = shellAliases;
  };
}


