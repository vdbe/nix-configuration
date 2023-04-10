{ lib, ... }:
let
  inherit (lib.my.import) listImportablePathsExcept;
in
{
  imports = listImportablePathsExcept ./. [ "default.nix" ];
}
