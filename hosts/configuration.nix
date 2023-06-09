{ lib, pkgs, inputs, ... }:

let
  inherit (lib) mkIf mkDefault;
  inherit (lib.my.modules) mapModulesRec';
  inherit (inputs) self;
in
{
  imports = [ ]
    ++ (mapModulesRec' ../modules/nixos import);

  modules = {
    nix.enable = true;
  };

  programs = {
    command-not-found.enable = false;
  };

  boot = {
    tmpOnTmpfs = mkDefault true;
    loader = {
      efi.canTouchEfiVariables = mkDefault true;
      systemd-boot = {
        enable = mkDefault true;
        configurationLimit = mkDefault 10;
      };
    };
  };

  fileSystems."/".device = mkDefault "/dev/disk/by-label/NIXOS";

  time.timeZone = mkDefault "Europe/Brussels";
  i18n.defaultLocale = mkDefault "en_US.UTF-8";

  networking = {
    firewall.enable = mkDefault true;
    useDHCP = mkDefault false;
    dhcpcd.wait = "background";
  };

  environment = {
    binsh = "${pkgs.dash}/bin/dash";
    #localBinInPath = true;

    systemPackages = with pkgs; [ dash ];
  };

  users = {
    mutableUsers = false;
    users = {
      root = {
        #hashedPassword = "*";
      };
    };
  };

  system = {
    configurationRevision = mkIf (self ? rev) self.rev;
    stateVersion = "22.11";
  };
}
