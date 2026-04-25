{
  inputs,
  self,
  ...
}: let
  inherit (inputs.nixpkgs) lib;
  u = self.workstationUser;
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
  imports = [
    inputs.home-manager.flakeModules.home-manager
    ./config.nix
  ];

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
