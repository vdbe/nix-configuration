inputs@{ lib, ... }:
let
  inherit (lib.my.nixos) mapHosts;
in
mapHosts ./. inputs
