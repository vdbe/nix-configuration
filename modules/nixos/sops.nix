{ config, lib, inputs, ... }:
with builtins;
with lib;
with lib.my;
let inherit (inputs) sops-nix;
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
