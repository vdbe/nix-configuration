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
  };

  # Environment
  xdg = {
    enable = true;
    userDirs.enable = true;
  };

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

