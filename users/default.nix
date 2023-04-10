inputs@{ lib, ... }:
let
  inherit (lib.my.home-manager) mapUsers;
in
mapUsers ./. inputs
