{ config, lib, pkgs, inputs, system, ... }:

{
  imports =
    [
      ./hardware.nix
      inputs.home-manager.nixosModules.home-manager
    ];

  modules = {
    sops.enable = true;
    services = {
      ssh.enable = true;
      fail2ban.enable = true;
    };
  };

  sops.secrets.hashed_password.neededForUsers = true;

  users.users.user = {
    isNormalUser = true;
    passwordFile = config.sops.secrets.hashed_password.path;
    shell = pkgs.fish;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
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

  services.xe-guest-utilities.enable = true;

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.user = ./../../users/user;
    #users.user = {imports = [./../../users/user ];};
    #users.user = import ./../../users/user { inherit config lib inputs system pkgs; };
    extraSpecialArgs = { inherit lib inputs system pkgs; };
  };

}
