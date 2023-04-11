{
  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }:
    let
      inherit (nixpkgs.lib) genAttrs;

      supportedSystems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = genAttrs supportedSystems;

      mkPkgs = system: pkgs: import pkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      packages = forAllSystems
        (system: import ./. { pkgs = mkPkgs system nixpkgs; });
    };
}
