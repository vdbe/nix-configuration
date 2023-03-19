{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;

  cfg = config.modules.desktop.terminals.alacritty;
in
{
  options.modules.desktop.terminals.alacritty = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    modules.desktop.terminals.default = "alacritty";

    programs.alacritty = {
      enable = true;

      settings = {
        env = {
          TERM = "xterm-256color";
          WINIT_X11_SCALE_FACTOR = "1.0";
        };

        window = {
          dynamic_padding = false;
          decorations = "full";
          opacity = 1.0;
          dynamic_title = true;
        };
      };

    };
  };
}

