{
  inputs,
  self,
  ...
}: let
  inherit (inputs.nixpkgs) lib;
  mkPkgs = system:
    import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  mkHome = host:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs host.system;
      modules =
        lib.attrValues self.homeModules
        ++ [
          {
            home.username = host.username;
            home.homeDirectory = host.homeDirectory;
            home.stateVersion = "26.05";
          }
        ];
    };
in {
  imports = [
    inputs.home-manager.flakeModules.home-manager
    ./config.nix
  ];

  options.flake.homeHosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
    default = {};
    description = "Per-host home-manager configuration attrs.";
  };

  config.flake.homeConfigurations =
    lib.mapAttrs'
    (name: host: lib.nameValuePair "${host.username}@${name}" (mkHome host))
    self.homeHosts;
}
