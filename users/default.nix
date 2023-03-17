{ lib, ... }:
with builtins;
with lib;
with lib.my;
{
  imports = [ ]
    ++ (mapModulesRec' (toString ../modules/home-manager) import);

  home = {
    stateVersion = "22.11";
  };
}
