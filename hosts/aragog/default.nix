# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, inputs, system, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware.nix

      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.nixos-hardware.nixosModules.common-pc-laptop
      inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
      inputs.nixos-hardware.nixosModules.common-pc-laptop-acpi_call

      inputs.home-manager.nixosModules.home-manager
    ];

  modules = {
    sops.enable = true;
    services = {
      ssh.enable = true;
      fail2ban.enable = true;
    };
    shell.fish.enable = true;
    desktop.hyprland.enable = true;
    yubikey.enable = true;
  };

  sops.secrets.hashed_password.neededForUsers = true;

  networking = {
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
  ];

  users.users.user = {
    isNormalUser = true;
    passwordFile = config.sops.secrets.hashed_password.path;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" "video" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBB774/7KJ/Y5k9jVF8YACJiyPKzU4PZs3brXbnMHtmq user@buckbeak"
    ];

    packages = with pkgs; [
      # firefox
      # thunderbird
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "user" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
        }
      ];
    }
  ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.user = ./../../users + "/user@${config.networking.hostName}";
    extraSpecialArgs = { inherit lib inputs system pkgs; system-modules = config.modules; };
  };
}

