{ lib, ... }:
let
  inherit (lib.my.import) importAllExcept;
in
importAllExcept ./. [ "default.nix" ]
