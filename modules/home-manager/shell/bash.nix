{ config, options, lib, ... }@attrs:

let
  inherit (lib) mkIf attrByPath;
  inherit (lib.my) mkBoolOpt;

  cfg = config.modules.shell.bash;
in
{
  options.modules.shell.bash = {
    enable = mkBoolOpt (attrByPath [ "system-modules" "shell" "fish" "enable" ] false attrs);
  };


  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
    };
  };
}

