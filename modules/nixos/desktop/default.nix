{ config, options, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkMerge mkOption;
  inherit (lib.types) nullOr enum;
  inherit (lib.my.attrs) countAttrs;

  cfg = config.modules.desktop;
in
{
  options.modules.desktop = {
    envProto = mkOption {
      type = nullOr (enum [ "x11" "wayland" ]);
      description = "What display protocol to use.";
      default = null;
    };
  };

  config = mkMerge [
    (mkIf (cfg.envProto != null)
      {
        assertions = [
          {
            assertion = (countAttrs (n: _v: n == "enable") cfg) < 2;
            message = "Prevent DE/WM > 1 from being enabled.";
          }
        ];


        fonts = {
          fontDir.enable = true;
          enableGhostscriptFonts = true;
          fonts = with pkgs; [
            ubuntu_font_family
            dejavu_fonts
            symbola
          ];
        };

        xdg.portal = {
          enable = true;
          extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        };

        # Retain secrets inside Gnome Keyring
        services.gnome.gnome-keyring.enable = true;

        # Functional `pkgs.light` for `/bin/brightctl`
        programs.light.enable = true;

        # Clean up leftovers, as much as we can
        system.userActivationScripts.cleanupHome = ''
          pushd ~
          rm -rf .compose-cache .nv .pki .dbus .fehbg
          [ -s .xsession-errors ] || rm -f .xsession-errors*
          popd
        '';

        modules.services.pipewire.enable = true;
      })


    (mkIf (cfg.envProto == "x11") {
      # TODO:
    })

    (mkIf (cfg.envProto == "wayland") {
      xdg.portal.wlr.enable = true;

      services.xserver = {
        enable = true;
        displayManager.gdm = {
          enable = true;
          wayland = true;
        };

        # TODO: Figure out what keeps installing xterm
        excludePackages = [ pkgs.xterm ];
        desktopManager.xterm.enable = false;
      };
    })
  ];
}
