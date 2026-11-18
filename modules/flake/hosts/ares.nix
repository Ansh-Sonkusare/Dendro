{
  self,
  inputs,
  ...
}: {
  flake.homeHosts.ares = {
    username = "teak";
    homeDirectory = "/home/teak";
    system = "x86_64-linux";
  };

  flake.nixosModules.aresModules = {pkgs, ...}: {
    imports = with self.nixosModules; [
      inputs.nixos-wsl.nixosModules.default
      base
      fonts
      homeManager
    ];

    networking.hostName = "ares";
    system.stateVersion = "26.05";

    programs.nix-index.enable = true;
    environment.systemPackages = [
      pkgs.wget
      pkgs.tailscale
      pkgs.home-manager
      pkgs.kubectl
      pkgs.prisma_6
      pkgs.graphite-cli
      pkgs.starship
    ];

    environment.variables = {
      PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines_6}/lib/libquery_engine.node";
      PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines_6}/bin/query-engine";
      PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines_6}/bin/schema-engine";
      PRISMA_TMP_DIR = "/tmp/prisma"; # Ensure this directory is writable
    };

    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune.enable = true;
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

    users.users.teak = {
      isNormalUser = true;
      home = "/home/teak";
      description = "teak user";
      shell = pkgs.zsh;
      extraGroups = ["wheel" "docker"];
    };

    home-manager.users.teak.home.sessionPath = ["$HOME/.local/bin"];
  };
}
