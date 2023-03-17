{ config, options, lib, ... }:

let
  inherit (lib) mkIf optionalAttrs;
  inherit (lib.my) mkBoolOpt;

  cfg = config.modules.shell.git;
in
{
  options.modules.shell.git = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      extraConfig = {
        init = { defaultBranch = "main"; };
      };

    } // optionalAttrs config.modules.shell.gpg.enable {
      userName = "vdbewout";
      userEmail = "vdbewout@gmail.com";

      signing = {
        key = "482AEE74BFCFD294EBBB4A247019E6C8EFE72BF0";
        signByDefault = true;
      };
    };
  };
}

