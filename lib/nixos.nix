{ lib, ... }:

with lib;
with lib.my;
let
  inherit (builtins) readDir;
  inherit (lib) pathIsDirectory lists nixosSystem;
  inherit (lib.my.import) getAttrWithDefault;

  configurationFile = "configuration.nix";
  defaultConfiguration = ../hosts + "/${configurationFile}";

in
rec {
  # mkHost = path: attrs @ { system ? "x86_64-linux", ... }:
  #   nixosSystem {
  #     inherit system;
  #     specialArgs = { inherit lib inputs system; };
  #     modules = [
  #       {
  #         nixpkgs.pkgs = pkgs."${system}";
  #         networking.hostName = mkDefault (removeSuffix ".nix" (baseNameOf path));
  #         system.nixos.tags = [ inputs.self.shortRev or "dirty" ];
  #       }
  #       (filterAttrs (n: _v: !elem n [ "system" ]) attrs)
  #       ../hosts # /hosts/default.nix
  #       (import path)
  #     ];
  #   };
  mkHost = configurationPath: attrs @ { lib, inputs, pkgs, ... }:
    let
      configuration = if (pathIsDirectory configurationPath) then configurationPath + "/${configurationFile}" else configurationPath;
      system = if (pathExists (configurationPath + "/system.nix")) then (import configurationPath + "/system.nix") else "x86_64-linux";
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
            networking.hostName = mkDefault (removeSuffix ".nix" (baseNameOf configurationPath));
            system.nixos.tags = [ inputs.self.shortRev or "dirty" ];
          }
          #(filterAttrs (n: _v: !elem n [ "system" ]) attrs)
          #../hosts # /hosts/default.nix
          defaultConfiguration
          (import configuration)
        ];
      };


  #mapHosts = dir: attrs:
  #  mapModules dir
  #    (hostPath: "hostPath");
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
