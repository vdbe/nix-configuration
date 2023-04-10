{ lib, ... }:

let
  inherit (lib) makeExtensible foldr attrValues;

  modules = import ./modules.nix {
    inherit lib;
    self.attrs = import ./attrs.nix { inherit lib; self = { }; };
  };

  mylib = makeExtensible (self:
    with self; modules.mapModulesRec ./.
      (file: import file { inherit self lib pkgs inputs; }));


in
mylib.extend
  (_self: super:
  foldr (a: b: a // b) { } (attrValues super))
