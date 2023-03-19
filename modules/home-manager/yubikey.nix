{ options, config, lib, pkgs, ... }@attrs:

let
  inherit (lib) mkIf attrByPath lists;
  inherit (lib.my) mkBoolOpt;
  system-modules = attrByPath [ "system-modules" ] null attrs;

  yubikeyEnable = attrByPath [ "yubikey" "enable" ] false system-modules;
  envProto = attrByPath [ "desktop" "envProto" ] null system-modules;

  cfg = config.modules.yubikey;
in
{
  options.modules.yubikey = {
    enable = mkBoolOpt yubikeyEnable;
    guis = mkBoolOpt (envProto != null);
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      yubikey-manager
      yubikey-personalization
    ] ++ lists.optionals cfg.guis [
      yubikey-personalization-gui
      unstable.yubioath-flutter
    ];
  };
}
