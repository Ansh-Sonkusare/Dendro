{
  inputs,
  self,
  ...
}: let
  inherit (inputs.nixpkgs) lib;
  u = self.lib.users.mkUser {name = self.lib.usernames.workstation;};
  current = builtins.tryEval builtins.currentSystem;
  system =
    if current.success
    then current.value
    else "x86_64-linux";
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
in {
  imports = [inputs.home-manager.flakeModules.home-manager];

  flake.homeModules = {
    packages = import ./packages.nix;
    programs = import ./programs/default.nix;
    tmux = import ./tmux.nix;
    base = {pkgs, ...}: {
      fonts.fontconfig.enable = true;
      programs.home-manager.enable = true;
      services.ssh-agent.enable = true;
    };

    homeserverHost = {pkgs, ...}: {
      home.packages = with pkgs; [
        lemonade
        cargo
        nodejs
        pnpm
        graphite-cli
        bun
      ];
    };
  };

  flake.homeConfigurations.default = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules =
      lib.attrValues self.homeModules
      ++ [
        {
          home.username = u.username;
          home.homeDirectory = u.homeDirectory;
          home.stateVersion = "26.05";
        }
      ];
  };
}