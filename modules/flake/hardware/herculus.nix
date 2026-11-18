{inputs, ...}: {
  flake.nixosModules.herculusHardware = {
    lib,
    modulesPath,
    config,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
      inputs.disko.nixosModules.disko
    ];

    boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-intel"];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/4e0e7730-b825-4797-a878-4055ded80ed7";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/58BA-D8FD";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };

    swapDevices = [];

    disko.devices.disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/ata-WDC_WD10SPZX-21Z10T0_WD-WXE1AC8ALV5R";
      content = {
        type = "gpt";
        partitions.data = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/hdd";
          };
        };
      };
    };

    services.xserver.videoDrivers = ["nvidia"];
    networking.useDHCP = lib.mkDefault true;
    networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
    networking.interfaces.wlp4s0.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
