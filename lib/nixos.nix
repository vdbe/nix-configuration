{ lib, ... }:

let
  inherit (builtins) dirOf pathExists readDir;
  inherit (lib) pathIsDirectory nixosSystem filterAttrs removeSuffix mkDefault;
  inherit (lib.my.attrs) getAttrWithDefault attrNames;
  inherit (lib.my.modules) mapModulesRecOn;

  configurationFile = "configuration.nix";
  defaultConfiguration = ../hosts + "/${configurationFile}";
in
rec {
  mkHost = configurationPath: attrs @ { lib, inputs, pkgs, ... }:
    let
      isDir = pathIsDirectory configurationPath;
      configurationDir = if isDir then configurationPath else (dirOf configurationPath);
      configuration = if isDir then configurationDir + "/${configurationFile}" else configurationPath;
      #isDefault = defaultConfiguration == configuration;
      hostName = if isDir then (removeSuffix ".nix" (baseNameOf configurationDir)) else "nixos";
      system = getAttrWithDefault
        (
          if (isDir && pathExists (configurationDir + "/system.nix"))
          then (import (configurationDir + "/system.nix")) else "x86_64-linux"
        ) "system"
        attrs;
    in
    #{
      #  inherit system hostName configurationDir configuration configurationPath;
      #};
    nixosSystem
      {
        inherit system;
        specialArgs = {
          inherit lib inputs system;
        };
        modules = [
          {
            nixpkgs.pkgs = pkgs."${system}";
            networking.hostName = mkDefault hostName;
            system.nixos.tags = [ inputs.self.shortRev or "dirty" ];
          }
          defaultConfiguration
          configuration
        ]; # ++ lists.optional (isDefault == false) defaultConfiguration
        #++ [ (import configuration) ];
      };

  listHost = dir:
    let
      conditionTable = n: {
        #regular = n == configurationFile;
        regular = false;
        directory = !pathExists (dir + "/${n}/${configurationFile}")
          && pathExists (dir + "/${n}/${configurationFile}");
      };
    in
    attrNames (filterAttrs (n: v: getAttrWithDefault false v (conditionTable n)) (readDir dir));


  mapHosts = dir: attrs:
    mapModulesRecOn dir configurationFile true (hostPath: mkHost hostPath attrs);
}
