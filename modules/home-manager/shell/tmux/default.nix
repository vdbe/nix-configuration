{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;

  cfg = config.modules.shell.tmux;
in
{
  options.modules.shell.tmux = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
    };

    xdg.configFile."tmux/tmux.conf".source = ./tmux.conf;
    xdg.configFile."tmux/theme.conf".source = ./theme.conf;
  };
}

