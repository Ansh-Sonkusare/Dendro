{
  self,
  inputs,
  ...
}: {
  flake.homeHosts.herculus = {
    username = "teak";
    homeDirectory = "/home/teak";
    system = "x86_64-linux";
  };

  flake.nixosModules.herculusModules = {pkgs, ...}: {
    imports = with self.nixosModules; [
      inputs.sops-nix.nixosModules.sops
      herculusHardware
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
      hermesService
      firecrawlService
    ];

    networking.hostName = "homeserver";
    system.stateVersion = "26.05";

    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
    };
    boot.loader.efi.canTouchEfiVariables = true;

    hardware.nvidia.open = false;
    hardware.nvidia.modesetting.enable = true;
    hardware.nvidia-container-toolkit.enable = false;
    environment.systemPackages = [pkgs.nvidia-container-toolkit];

    services.openiscsi.name = "iqn.2016-04.com.open-iscsi:herculus";
    networking.firewall.trustedInterfaces = ["tailscale0" "enp3s0"];
  };
}
