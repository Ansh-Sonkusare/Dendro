{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD10SPZX-21Z10T0_WD-WXE1AC8ALV5R";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/hdd";
              };
            };
          };
        };
      };
    };
  };
}