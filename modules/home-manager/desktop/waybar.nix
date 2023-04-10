{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf types;
  inherit (lib.my.options) mkBoolOpt mkOpt;

  cfg = config.modules.desktop.waybar;
in
{
  options.modules.desktop.waybar = {
    enable = mkBoolOpt false;
    package = mkOpt types.package pkgs.waybar;
  };

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      inherit (cfg) package;

      #settings = {
      #  mainBar = {
      #    layer = "top";
      #    position = "top";
      #    height = 30;
      #    output = [
      #      "eDP-1"
      #      "HDMI-A-1"
      #    ];
      #    modules-left = [ "sway/workspaces" "sway/mode" "wlr/taskbar" ];
      #    modules-center = [ "sway/window" ];
      #    modules-right = [ "mpd" "custom/mymodule#with-css-id" "temperature" ];
      #    "sway/workspaces" = {
      #      disable-scroll = true;
      #      all-outputs = true;
      #    };
      #  };
      #};

      settings = [{
        "layer" = "top";
        "position" = "bottom";
        modules-left = [
          "custom/launcher"
          "wlr/workspaces"
        ];
        modules-right =
          [ "memory" "cpu" "network" "battery" "custom/powermenu" "tray" ];
        "custom/launcher" = {
          "format" = " ";
          "on-click" = "rofi -no-lazy-grab -show drun -modi drun";
          "tooltip" = false;
        };
        "wlr/workspaces" = {
          "format" = "{icon}";
          "on-click" = "activate";
          "on-scroll-up" = "hyprctl dispatch workspace e+1";
          "on-scroll-down" = "hyprctl dispatch workspace e-1";
        };
        "idle_inhibitor" = {
          "format" = "{icon}";
          "format-icons" = {
            "activated" = "";
            "deactivated" = "";
          };
          "tooltip" = false;
        };
        "battery" = {
          "interval" = 10;
          "states" = {
            "warning" = 20;
            "critical" = 10;
          };
          "format" = "{icon} {capacity}%";
          "format-icons" = [ "" "" "" "" "" "" "" "" "" ];
          "format-full" = "{icon} {capacity}%";
          "format-charging" = " {capacity}%";
          "tooltip" = false;
        };
        "clock" = {
          "interval" = 1;
          "format" = "{:%I:%M %p  %A %b %d}";
          "tooltip" = true;
        };
        "memory" = {
          "interval" = 1;
          "format" = "﬙ {percentage}%";
          "states" = { "warning" = 85; };
        };
        "cpu" = {
          "interval" = 1;
          "format" = " {usage}%";
        };
        "mpd" = {
          "max-length" = 25;
          "format" = "<span foreground='#bb9af7'></span> {title}";
          "format-paused" = " {title}";
          "format-stopped" = "<span foreground='#bb9af7'></span>";
          "format-disconnected" = "";
          "on-click" = "mpc --quiet toggle";
          "on-click-right" = "mpc ls | mpc add";
          "on-click-middle" = "kitty --class='ncmpcpp' --hold sh -c 'ncmpcpp'";
          "on-scroll-up" = "mpc --quiet prev";
          "on-scroll-down" = "mpc --quiet next";
          "smooth-scrolling-threshold" = 5;
          "tooltip-format" =
            "{title} - {artist} ({elapsedTime:%M:%S}/{totalTime:%H:%M:%S})";
        };
        "network" = {
          "interval" = 1;
          "format-wifi" = "說 {essid}";
          "format-ethernet" = "  {ifname} ({ipaddr})";
          "format-linked" = "說 {essid} (No IP)";
          "format-disconnected" = "說 Disconnected";
          "tooltip" = false;
        };
        "temperature" = {
          # "hwmon-path"= "${env:HWMON_PATH}";
          "critical-threshold" = 80;
          "tooltip" = false;
          "format" = " {temperatureC}°C";
        };
        "custom/powermenu" = {
          "format" = "";
          "on-click" = "shutdown";
          "tooltip" = false;
        };
        "tray" = {
          "icon-size" = 15;
          "spacing" = 5;
        };
      }];

    };
  };
}




