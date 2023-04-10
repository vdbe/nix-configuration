{ pkgs, config, ... }:
{
  imports = [
    ../modules/home-manager
  ];

  home = {
    homeDirectory = "/${
        if pkgs.stdenv.isDarwin then "Users" else "home"
      }/${config.home.username}";

    stateVersion = "22.11";
  };
}
