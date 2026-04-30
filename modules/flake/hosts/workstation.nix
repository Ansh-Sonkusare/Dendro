{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.workstationModules = {
    pkgs,
    lib,
    ...
  }: let
    user = self.lib.users.mkUser {name = self.lib.usernames.workstation;};
    host = self.lib.hosts.workstation;
    sharedSystemPackages = import ../lib/system-packages.nix {inherit pkgs;};
  in {
    imports = [
      inputs.home-manager.nixosModules.default
      inputs.vscode-server.nixosModules.default
      inputs.nixos-wsl.nixosModules.default
    ];

    services.vscode-server.enable = true;

    system.stateVersion = "26.05";

    environment.systemPackages = sharedSystemPackages ++ [
      pkgs.prisma
      pkgs.graphite-cli
    ];
    nixpkgs.config.allowUnfree = true;

    # Prisma:
    environment.variables = {
      PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";
      PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/query-engine";
      PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
      PRISMA_TMP_DIR = "/tmp/prisma"; # Ensure this directory is writable
    };

    networking.hostName = host.hostname;
    programs.zsh.enable = true;
    programs.nix-ld.enable = true;

    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune.enable = true;
    };

    services.tailscale.enable = true;
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
      defaultUser = user.username;
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

    users.users.${user.username} = {
      isNormalUser = true;
      home = user.homeDirectory;
      description = "${user.username} user";
      extraGroups = ["wheel"];
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      extraSpecialArgs = {
        inherit inputs;
      };

      users.${user.username} = {
        imports =
          lib.attrValues self.homeModules;

        home = {
          username = user.username;
          homeDirectory = user.homeDirectory;
          stateVersion = "26.05";
          sessionPath = ["$HOME/.local/bin"];
        };

        programs.home-manager.enable = true;
      };
    };
  };
}
