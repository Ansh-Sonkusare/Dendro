{
  self,
  inputs,
  ...
}: let
  workstationUsername = "teak";
  workstationHomeDirectory = "/home/${workstationUsername}";
in {
  flake.workstationUser = {
    username = workstationUsername;
    homeDirectory = workstationHomeDirectory;
  };

  flake.nixosModules.workstationModules = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      inputs.home-manager.nixosModules.default
      inputs.vscode-server.nixosModules.default
      inputs.nixos-wsl.nixosModules.default
    ];

    nix.settings.experimental-features = ["nix-command" "flakes"];
    services.vscode-server.enable = true;

    system.stateVersion = "26.05";

    environment.systemPackages = [
      pkgs.wget
      pkgs.tailscale
      pkgs.home-manager
      pkgs.kubectl
      pkgs.prisma
      pkgs.graphite-cli
      pkgs.starship
    ];
    nixpkgs.config.allowUnfree = true;
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
    ];

    # Prisma:
    environment.variables = {
      PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";
      PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/query-engine";
      PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
      PRISMA_TMP_DIR = "/tmp/prisma"; # Ensure this directory is writable
    };

    networking.hostName = "nixos";
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
      defaultUser = workstationUsername;
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

    users.users.${workstationUsername} = {
      isNormalUser = true;
      home = workstationHomeDirectory;
      description = "${workstationUsername} user";
      shell = pkgs.zsh;
      extraGroups = ["wheel"];
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      extraSpecialArgs = {
        inherit inputs;
      };

      users.${workstationUsername} = {
        imports =
          lib.attrValues self.homeModules;

        home = {
          username = workstationUsername;
          homeDirectory = workstationHomeDirectory;
          stateVersion = "26.05";
          sessionPath = ["$HOME/.local/bin"];
        };

        programs.home-manager.enable = true;
        services.ssh-agent.enable = true;
      };
    };
  };
}
