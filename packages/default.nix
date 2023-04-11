{ pkgs ? (import <nixpkgs> { }), ... }:
let
  inherit (builtins) attrNames elem filter getAttr hasAttr listToAttrs mapAttrs map pathExists readDir;
  inherit (pkgs.lib) filterAttrs hasSuffix nameValuePair removeSuffix;

  getAttrWithDefault = default: attr: set:
    if hasAttr attr set then getAttr attr set else default;

  listImportable = dir:
    let
      conditionTable = n: {
        regular = hasSuffix ".nix" n;
        directory = pathExists (dir + "/${n}/default.nix");
      };
    in
    attrNames (filterAttrs (n: v: getAttrWithDefault false v (conditionTable n)) (readDir dir));

  listImportableExcept = dir: except:
    filter
      (n: ! elem n except)
      (listImportable dir);

  #importAllExcept = dir: except: arg:
  #  listToAttrs (map (n: nameValuePair (removeSuffix ".nix" n) (import (dir + "/${ n}") arg)) (listImportableExcept dir except));
  importAllExcept = dir: except:
    listToAttrs (map (n: nameValuePair (removeSuffix ".nix" n) (import (dir + "/${ n}"))) (listImportableExcept dir except));
  #importAllExcept = dir: except:
  #  map (n: nameValuePair (removeSuffix ".nix" n) (import (dir + "/${ n}"))) (listImportableExcept dir except);

  packages = importAllExcept ./. [ "default.nix" "flake.nix" ];
in
filterAttrs (_n: p: ! p? meta || ! p.meta? platforms || elem pkgs.system p.meta.platforms) (
  mapAttrs (_n: v: pkgs.callPackage v { }) packages
)
