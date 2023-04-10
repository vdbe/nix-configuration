inputs@{ lib, ... }:
let
  inherit (lib.my.import) importAllExceptWithArg;
in
importAllExceptWithArg ./. [ "default.nix" ] inputs
