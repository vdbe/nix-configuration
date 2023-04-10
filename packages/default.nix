{ pkgs, lib, ... }:
let
  inherit (builtins) elem mapAttrs;
  inherit (lib) filterAttrs;
  inherit (lib.my.import) importAllExcept;
in
filterAttrs (_n: p: ! p ? meta || ! p.meta ? platforms || elem pkgs.system p.meta.platforms) (
  mapAttrs (_n: v: pkgs.callPackage v { }) (importAllExcept ./. [ "default.nix" ])
)
