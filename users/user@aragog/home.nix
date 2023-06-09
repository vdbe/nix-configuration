{ config, pkgs, inputs, ... }: {
  imports = [ ./../user/home.nix ];

  modules = {
    desktop = { browsers = { firefox.enable = true; }; };
    shell = { bitwarden-cli.enable = true; };
    yubikey.enable = true;
  };

  home = {
    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = config.modules.desktop.browsers.default;
      TERMINAL = config.modules.desktop.terminals.default;
    };

    packages = with pkgs; [
      firefox
      nerdfonts
      # nerdfonts.override # Only install FiraCode
      # { fonts = [ "FiraCode" ]; }

      discord
      unstable.bitwarden
      steam
      my.maelstrom
      inputs.devenv.packages.x86_64-linux.devenv
    ];
  };
}
