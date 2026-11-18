{self, ...}: {
  flake.homeHosts.aphrodite = {
    username = "anshsonkusare";
    homeDirectory = "/Users/anshsonkusare";
    system = "aarch64-darwin";
  };

  flake.darwinModules.aphroditeModule = {pkgs, ...}: {
    imports = with self.darwinModules; [
      nix
      homebrew
      homeManager
    ];

    system.stateVersion = 6;
    system.primaryUser = "anshsonkusare";

    users.users.anshsonkusare = {
      name = "anshsonkusare";
      home = "/Users/anshsonkusare";
    };

    # Create /etc/bashrc that loads the nix-darwin environment.
    programs.zsh.enable = true;
    programs.nix-index.enable = true;

    # GUI apps go here: home-manager can't add them to ~/Applications (home-manager#1341)
    environment.systemPackages = with pkgs; [
      direnv
      nushell
      kitty
      terminal-notifier
    ];
    environment.extraInit = ''
      export PATH=$HOME/.opencode/bin:$PATH
    '';

    system.keyboard.enableKeyMapping = false;
    system.keyboard.remapCapsLockToEscape = false;
    security.pam.services.sudo_local.touchIdAuth = true;
    system.defaults = {loginwindow.LoginwindowText = "TeakMirror113";};
  };
}
