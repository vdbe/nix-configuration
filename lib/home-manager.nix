{ lib, ... }:

let
  inherit (builtins) readDir dirOf listToAttrs pathExists attrNames;
  inherit (lib) pathIsDirectory filterAttrs nameValuePair removeSuffix;
  inherit (lib.my.import) getAttrWithDefault;

  configurationFile = "home.nix";
  #defaultConfiguration = ../users + "/${configurationFile}";
in
rec {
  mkHomeLib = lib: inputs: lib.extend (_self: _super: inputs.home-manager.lib);

  mkExtraSpecialArgs = { config, lib, pkgs, inputs, system }: {
    inherit inputs system pkgs;
    system-modules = config.modules;
    lib = mkHomeLib lib inputs;
  };

  mkUser = configurationPath: attrs @ { inputs, pkgs, ... }:
    let
      inherit (inputs.home-manager.lib) homeManagerConfiguration;

      isDir = pathIsDirectory configurationPath;
      configurationDir = if isDir then configurationPath else (dirOf configurationPath);
      configuration = if isDir then configurationDir + "/${configurationFile}" else configurationPath;
      #isDefault = defaultConfiguration == configuration;
      system = getAttrWithDefault
        (
          if (isDir && pathExists (configurationDir + "/system.nix"))
          then (import (configurationDir + "/system.nix")) else "x86_64-linux"
        ) "system"
        attrs;

      homeLib = mkHomeLib attrs.lib inputs;
    in
    homeManagerConfiguration
      {
        extraSpecialArgs = {
          inherit inputs system;
          lib = homeLib;
        };
        pkgs = pkgs."${system}";
        modules = [
          # This won't be imported if homeManager is used as an NixOS module
          #defaultConfiguration
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


  mapUsers = dir: attrs:
    listToAttrs (map (n: nameValuePair (removeSuffix ".nix" n) (mkUser (dir + "/${n}") attrs)) (listHost dir));
}
