{ options, config, lib, ... }@attrs:

let
  inherit (lib) mkIf mkMerge mkOption attrByPath;
  inherit (lib.types) str;
  inherit (lib.my.import) listImportablePathsExcept;

  envProto = attrByPath [ "system-modules" "desktop" "envProto" ] null attrs;

  #cfg = config.modules.desktop.terminals;
in
{
  imports = listImportablePathsExcept ./. [ "default.nix" ];

  options.modules.desktop.terminals = {
    default = mkOption {
      type = str;
      default = "alacritty";
      description = "Default terminal";
      example = "kitty";
    };
  };

  config = mkIf (envProto != null) (mkMerge [
    { }

    (mkIf (config.modules.desktop.envProto == "x11") { })

    (mkIf (config.modules.desktop.envProto == "wayland") { })
  ]);
}
