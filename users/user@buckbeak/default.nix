{ pkgs, system, inputs, ... }:
let username = "user";
in {
  imports = [
    #./../user
  ];

  modules = {
    shell = { bitwarden-cli.enable = true; };
    nix.enable = true;
  };

  home = {
    username = "${username}";
    sessionVariables = { };

    packages = with pkgs; [ inputs.devenv.packages."${pkgs.system}".devenv ];
  };
}
