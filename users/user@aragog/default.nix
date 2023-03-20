{ config, pkgs, ... }:

{
  imports = [
    ./../user
  ];

  modules = {
    desktop = {
      browsers = {
        firefox.enable = true;
      };
    };
    shell = {
      bitwarden-cli.enable = true;
    };
    yubikey.enable = true;
  };

  # Environment

  #programs.alacritty = {
  #  enable = true;
  #};

  home = {
    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "firefox";
      TERMINAL = config.modules.desktop.terminals.default;
    };

    packages = with pkgs; [
      firefox
      nerdfonts
      #nerdfonts.override # Only install FiraCode
      #{ fonts = [ "FiraCode" ]; }
    ];
  };

}

