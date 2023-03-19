{ config, options, lib, pkgs, inputs, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;

  cfg = config.modules.desktop.hyprland;
in
{
  # TODO: Make this optional somehow
  imports = [ inputs.hyprland.nixosModules.default ];


  options.modules.desktop.hyprland = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    modules.desktop.envProto = "wayland";

    services.xserver = {
      enable = true;
      displayManager = {
        defaultSession = "hyprland";
        gdm = {
          enable = true;
          wayland = true;
        };
      };
    };
    hardware = {
      opengl = {
        enable = true;
        driSupport = true;
        #driSupport32Bit = true;
        extraPackages = with pkgs; [
          vaapiVdpau
          libvdpau-va-gl
          mesa
        ];
      };
      #pulseaudio.support32Bit = true;
    };

    sound = {
      enable = true;
      #mediaKeys.enable = true;
    };

    programs.hyprland.enable = true;
  };
}

