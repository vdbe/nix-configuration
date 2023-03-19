{ config, options, lib, ... }@attrs:

let
  inherit (lib) mkIf attrByPath;
  inherit (lib.my) mkBoolOpt;

  cfg = config.modules.shell.fish;
in
{
  options.modules.shell.fish = {
    enable = mkBoolOpt (attrByPath [ "system-modules" "shell" "fish" "enable" ] false attrs);
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        # Disable greeting message
        set --universal fish_greeting
      '';
    };
  };
}

