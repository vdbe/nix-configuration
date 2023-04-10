# Copied from https://github.com/tejing1/nixos-config
{ lib, ... }:
let
  inherit (builtins) listToAttrs;
  inherit (lib) nameValuePair;

  # functions needed to construct 'lib' itself
  bootstrapFunctions = [
    "importAllExceptWithArg"
    "listImportableExcept"
    "listImportable"
    "getAttrWithDefault"
  ];

  # arguments to files in this directory during bootstrap
  initialArgs = { inherit lib; my.lib = initialLib; };

  # bootstrap lib containing only 'bootstrapFunctions'
  initialLib = listToAttrs (map (n: nameValuePair n (import (./. + "/${n}.nix") initialArgs)) bootstrapFunctions);

  # arguments to files for externally visible 'lib'
  finalArgs = initialArgs // { my.lib = finalLib; };

  # externally visible 'lib'
  finalLib = initialLib.importAllExceptWithArg ./. [ "default.nix" ] finalArgs;

in
finalLib
