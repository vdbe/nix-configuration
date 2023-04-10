{ options, config, lib, pkgs, ... }@attrs:

let
  inherit (lib) mkIf mkOption getExe attrByPath;
  inherit (lib.types) package;
  inherit (lib.my.options) mkBoolOpt;

  envProto = attrByPath [ "system-modules" "desktop" "envProto" ] null attrs;

  cfg = config.modules.desktop.rofi;
in
{
  options.modules.desktop.rofi = {
    enable = mkBoolOpt false;
    package = mkOption {
      type = package;
      default =
        if (envProto == "wayland") then pkgs.rofi-wayland else pkgs.rofi;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ rofi-systemd ];

    programs.rofi = {
      enable = true;
      inherit (cfg) package;
      plugins = with pkgs; [ rofi-emoji rofi-power-menu ];
      theme = "gruvbox-dark-soft";

      extraConfig = {
        terminal = "${getExe config.modules.desktop.terminals.default}";
        disable-history = false;
        show-icons = true;
        sidebar-mode = false;
        sort = true;

        drun-display-format = "{icon} {name}";

        display-drun = "   Run ";
        display-emoji = "   Emoji ";
        display-window = "  Window ";
        display-power-menu = "  Power Menu ";

        modi = "run,drun,filebrowser,emoji,power-menu:${
            getExe pkgs.rofi-power-menu
          }";

        xoffset = 0;
        yoffset = 0;
      };
    };
  };
}
