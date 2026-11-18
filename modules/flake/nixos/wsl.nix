{inputs, ...}: {
  flake.nixosModules.wsl = {pkgs, ...}: {
    imports = [inputs.nixos-wsl.nixosModules.default];

    wsl = {
      enable = true;
      wslConf.automount.root = "/mnt";
      wslConf.interop.appendWindowsPath = false;
      wslConf.network.generateHosts = false;

      startMenuLaunchers = true;

      docker-desktop.enable = false;
      defaultUser = "teak";
      extraBin = with pkgs; [
        {src = "${coreutils}/bin/mkdir";}
        {src = "${coreutils}/bin/cat";}
        {src = "${coreutils}/bin/whoami";}
        {src = "${coreutils}/bin/ls";}
        {src = "${busybox}/bin/addgroup";}
        {src = "${su}/bin/groupadd";}
        {src = "${su}/bin/usermod";}
      ];
    };

    systemd.user = {
      paths.vscode-remote-workaround = {
        wantedBy = ["default.target"];
        pathConfig.PathChanged = "%h/.vscode-server/bin";
      };
      services.vscode-remote-workaround.script = ''
        for i in ~/.vscode-server/bin/*; do
          if [ -e $i/node ]; then
            echo "Fixing vscode-server in $i..."
            ln -sf ${pkgs.nodejs_22}/bin/node $i/node
          fi
        done
      '';
    };
  };
}
