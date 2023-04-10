{ lib, pkgs, config, ... }:
let

  inherit (lib.my.modules) mapModulesRec';
in
{
  imports = [ ]
    ++ (mapModulesRec' ../modules/home-manager import);

  home = {
    homeDirectory = "/${
        if pkgs.stdenv.isDarwin then "Users" else "home"
      }/${config.home.username}";

    stateVersion = "22.11";
  };
}
