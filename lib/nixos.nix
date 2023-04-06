{ inputs, pkgs, lib, ... }:

with lib;
with lib.my;
{
  mkHost = path: attrs @ { system ? "x86_64-linux", ... }:
    nixosSystem {
      inherit system;
      specialArgs = { inherit lib inputs system; };
      modules = [
        {
          nixpkgs.pkgs = pkgs."${system}";
          networking.hostName = mkDefault (removeSuffix ".nix" (baseNameOf path));
          system.nixos.tags = [ inputs.self.shortRev or "dirty" ];
        }
        (filterAttrs (n: _v: !elem n [ "system" ]) attrs)
        ../hosts # /hosts/default.nix
        (import path)
      ];
    };

  mapHosts = dir: attrs:
    mapModules dir
      (hostPath: mkHost hostPath attrs);
}
