{ config, lib, inputs, ... }:
let inherit (inputs) sops-nix;
  inherit (lib) mkOption types mkIf;
  inherit (lib.my.options) mkBoolOpt;

  cfg = config.modules.sops;
in
{
  imports = [ sops-nix.nixosModules.sops ];

  options.modules.sops = {
    enable = mkBoolOpt false;

    defaultSopsFile = mkOption {
      default = ../../secrets/default.sops.yaml;
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    sops = {
      inherit (cfg) defaultSopsFile;
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
}
