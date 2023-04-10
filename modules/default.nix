inputs@{ lib, ... }:
let
  inherit (lib.my.import) importAllExceptWithArg;
in
{
  #import = [
  #  (importAllExceptWithArg ./. [ "default.nix" ] inputs)
  #];

}
