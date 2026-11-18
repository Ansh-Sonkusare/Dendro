{self, ...}: {
  flake.homeHosts.ares = {
    username = "teak";
    homeDirectory = "/home/teak";
    system = "x86_64-linux";
  };

  flake.nixosModules.aresModules = {pkgs, ...}: {
    imports = with self.nixosModules; [
      wsl
      base
      fonts
      homeManager
      docker
      prisma
    ];

    networking.hostName = "ares";
    system.stateVersion = "26.05";

    programs.nix-index.enable = true;
    environment.systemPackages = with pkgs; [
      wget
      tailscale
      home-manager
      kubectl
      graphite-cli
      starship
    ];

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
