{
  self,
  inputs,
  ...
}: let
  username = "anshsonkusare";
  homeDirectory = "/Users/${username}";
in {
  flake.darwinModules.macintoshModule = {
    pkgs,
    lib,
    ...
  }: {
    # Nix configuration ------------------------------------------------------------------------------
    imports = [inputs.home-manager.darwinModules.home-manager];
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
    # services.nix-daemon.enable = true;
    nix.enable = false;

    users.users.anshsonkusare = {
      name = username;
      home = homeDirectory;
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
    ids.gids.nixbld = 30000;
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

      users.${username} = {
        imports = lib.attrValues self.homeModules;

        home = {
          username = username;
          inherit homeDirectory;
          stateVersion = "26.05";
          sessionPath = ["$HOME/.local/bin"];
        };

        programs.home-manager.enable = true;
        services.ssh-agent.enable = true;
      };
    };
    # Set state version (required)
    system.stateVersion = 6;

    system.defaults = {loginwindow.LoginwindowText = "TeakMirror113";};
  };
}
