{ config, options, lib, ... }:

let
  inherit (lib) mkIf optionalAttrs;
  inherit (lib.my) mkBoolOpt;

  cfg = config.modules.shell.git;

  aliases = { } // optionalAttrs cfg.enableAliases {
    root = "rev-parse --show-toplevel";
    exec = "!exec ";

    lc = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
    lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(bold cyan)%aD%C(reset) %C(bold yellow)%d%C(reset)%n'' %C(white)%s%C(reset) %C(dim white)- %an (%ae)%C(reset)' --all";
  };

  shellAliases = { } // optionalAttrs cfg.enableShellAliases {
    g = "git";
    gcd = "cd \"$(git root)\"";
  };
in
{
  options.modules.shell.git = {
    enable = mkBoolOpt false;
    enableAliases = mkBoolOpt true;
    enableShellAliases = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    programs = {
      git = {
        enable = true;
        inherit aliases;
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

      fish.shellAbbrs = shellAliases;
    };
    home.shellAliases = shellAliases;
  };
}

