{ lib, pkgs, config, ... }:
with builtins;
with lib;
with lib.my; {
  imports = [ ] ++ (mapModulesRec' (toString ../modules/home-manager) import);

  home = {
    homeDirectory = "/${
        if pkgs.stdenv.isDarwin then "Users" else "home"
      }/${config.home.username}";

    stateVersion = "22.11";
  };
}
