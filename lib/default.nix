{ lib, ... }:

let
  inherit (lib) makeExtensible foldr attrValues;

  initialLib = import ./import {
    inherit lib;
  };

  mylib = initialLib.importAllExceptWithArg ./. [ "default.nix" ] { inherit lib; };
  #mylib = makeExtensible (self: initialLib.importAllExceptWithArg ./. [ "default.nix" ] { inherit lib; });

in
mylib
#mylib.extend
#  (_self: super:
#    foldr (a: b: a // b) { } (attrValues super))
