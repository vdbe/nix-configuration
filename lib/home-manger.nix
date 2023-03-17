{ inputs, lib, pkgs, ... }:

let
  inherit (builtins) elem;
  inherit (lib) filterAttrs;
  inherit (lib.my) mapModules mkUser;
  inherit (inputs) home-manager;
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
in
{
  mkUser = path: attrs @ { system ? "x86_64-linux", ... }:
    homeManagerConfiguration {
      #inherit system;
      extraSpecialArgs = { inherit lib inputs system; };
      pkgs = pkgs."${system}";
      modules = [
        (filterAttrs (n: _v: !elem n [ "system" ]) attrs)
        ../users # /users/default.nix
        (import path)
      ];
    };

  mapUsers = dir: attrs:
    mapModules dir
      (hostPath: mkUser hostPath attrs);
}

