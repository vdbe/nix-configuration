{ config, pkgs, options, lib, inputs, ... }@attrs:

let
  inherit (builtins) readFile;
  inherit (lib) mkIf attrByPath;
  inherit (lib.my.options) mkBoolOpt;
  inherit (inputs) hyprland;

  cfg = config.modules.desktop.hyprland;
in
{
  imports = [
    # TODO: Make this optional somehow
    hyprland.homeManagerModules.default
  ];


  options.modules.desktop.hyprland = {
    enable = mkBoolOpt (attrByPath [ "system-modules" "desktop" "hyprland" "enable" ] false attrs);
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ hyprland.overlays.default ];

    wayland.windowManager.hyprland = {
      enable = true;
      systemdIntegration = true;
      recommendedEnvironment = true;
      extraConfig = readFile ./hyprland.conf;
    };

    modules = {
      desktop = {
        terminals.alacritty.enable = true;
        waybar = {
          enable = true;
          package = hyprland.packages."${pkgs.system}".waybar-hyprland;
        };
        rofi.enable = true;
        dunst.enable = true;
      };
    };

    xdg = {
      enable = true;
      mime.enable = true;
      mimeApps.enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
      };
    };

    home.packages = with pkgs;
      [
        hyprpaper
        libnotify
        playerctl
        volctl
        wf-recorder
        wl-clipboard
        wlr-randr
        wireplumber
      ];

  };
}

