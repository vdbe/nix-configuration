{ lib, ... }:

let
  inherit (builtins) readDir dirOf listToAttrs pathExists attrNames;
  inherit (lib) pathIsDirectory nixosSystem filterAttrs nameValuePair removeSuffix mkDefault;
  inherit (lib.my.import) getAttrWithDefault;

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
        directory = pathExists (dir + "/${n}/${configurationFile}");
      };
    in
    attrNames (filterAttrs (n: v: getAttrWithDefault false v (conditionTable n)) (readDir dir));


  mapHosts = dir: attrs:
    listToAttrs (map (n: nameValuePair (removeSuffix ".nix" n) (mkHost (dir + "/${n}") attrs)) (listHost dir));
}
