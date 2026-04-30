{
  self,
  inputs,
  ...
}: {
  flake.darwinModules.macintoshModule = {
    pkgs,
    lib,
    ...
  }: let
    user = self.lib.users.mkUser {
      name = self.lib.usernames.macintosh;
      system = "darwin";
    };
    host = self.lib.hosts.macintosh;
  in {
    # Nix configuration ------------------------------------------------------------------------------
    imports = [
      inputs.home-manager.darwinModules.home-manager
      inputs.sops-nix.nixosModules.sops
    ];
    # Enable experimental nix command and flakes
    # nix.package = pkgs.nixUnstable;
    nix.extraOptions =
      ''
        auto-optimise-store = true
        experimental-features = nix-command flakes
      ''
      + lib.optionalString (pkgs.system == "aarch64-darwin") ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';

    # Create /etc/bashrc that loads the nix-darwin environment.
    programs.zsh.enable = true;

    # Auto upgrade nix package and the daemon service.
    nix.enable = true;
    nix.linux-builder.enable = true;
    nix.settings.trusted-users = host.trustedUsers;
    users.users.anshsonkusare = {
      name = user.username;
      home = user.homeDirectory;
    };
    # Apps
    # `home-manager` currently has issues adding them to `~/Applications`
    # Issue: https://github.com/nix-community/home-manager/issues/1341
    environment.systemPackages = with pkgs; [
      direnv
      nushell
      kitty
      terminal-notifier
    ];
    environment.extraInit = ''
      export PATH=$HOME/.opencode/bin:$PATH
    '';
    # https://github.com/nix-community/home-manager/issues/423∂
    programs.nix-index.enable = true;

    # Fonts
    ids.gids.nixbld = 350;
    system.primaryUser = "anshsonkusare";
    homebrew.enable = true;

    homebrew.casks = ["alacritty" "wireshark" "ghostty" "nikitabobko/tap/aerospace"];
    homebrew.brews = [
      "imagemagick"

      "charmbracelet/tap/crush"
    ];
    # Keyboard
    system.keyboard.enableKeyMapping = false;
    system.keyboard.remapCapsLockToEscape = false;
    security.pam.services.sudo_local.touchIdAuth = true;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      users.${user.username} = {
        imports = lib.attrValues self.homeModules;

        home = {
          username = user.username;
          homeDirectory = user.homeDirectory;
          stateVersion = "26.05";
          sessionPath = ["$HOME/.local/bin"];
        };

        programs.home-manager.enable = true;
      };
    };

    sops.defaultSopsFile = ./secrets/secrets.yaml;
    sops.defaultSopsFormat = "yaml";
    sops.age.keyFile = "${user.homeDirectory}/.config/sops/age/keys.txt";

    # Set state version (required)
    system.stateVersion = 6;

    system.defaults = {loginwindow.LoginwindowText = "TeakMirror113";};
  };
}
