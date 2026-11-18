{self, ...}: {
  flake.homeHosts.atlas = {
    username = "teak";
    homeDirectory = "/home/teak";
    system = "x86_64-linux";
  };

  flake.nixosModules.atlasModules = {lib, ...}: let
    teakemitchy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIELO3esIBKAMiXWl6pK8ZCZBwjG7XupHg0y4WGmCRvXe teakemitchy@proton.me";
  in {
    imports = with self.nixosModules; [
      atlasHardware
      base
      fonts
      homeManager
      server
      k3s
      podman
      openssh
      locale
      desktop
      audio
      bluetooth
    ];

    networking.hostName = "atlas";
    system.stateVersion = "26.05";

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    services.openiscsi.name = "iqn.2016-04.com.open-iscsi:atlas";
    services.tailscale.extraSetFlags = ["--ssh" "--operator=teak"];
    networking.firewall.trustedInterfaces = ["tailscale0" "eno1"];

    users.users.teak.openssh.authorizedKeys.keys = lib.mkAfter [teakemitchy];
    users.users.root.openssh.authorizedKeys.keys = [teakemitchy];

    home-manager.backupFileExtension = "bak";
  };
}
