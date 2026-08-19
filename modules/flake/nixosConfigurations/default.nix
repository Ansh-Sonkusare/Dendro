{
  inputs,
  self,
  ...
}: let
  inherit (inputs.nixpkgs) lib;

  inherit (inputs.darwin.lib) darwinSystem;
  inherit (inputs.nixpkgs.lib) attrValues optionalAttrs;

  nushellOverlay = final: prev: {
    nushell = prev.nushell.overrideAttrs (_: {doCheck = false;});
  };

  nixpkgsConfig = {
    config.allowUnfree = true;
    overlays = [nushellOverlay self.overlays.default];
  };

  mkNixosConfig = args: let
    extraFn = args.extraHomePackages or null;
    extraModule = lib.optional (extraFn != null) (
      {pkgs, ...}: {
        home-manager.users.teak.home.packages = extraFn pkgs;
      }
    );
  in
    lib.nixosSystem ((builtins.removeAttrs args ["extraHomePackages"])
      // {
        modules = args.modules ++ extraModule;
      });

  mkDarwinConfig = args: let
    extraFn = args.extraHomePackages or null;
    extraModule = lib.optional (extraFn != null) (
      {pkgs, ...}: {
        home-manager.users.anshsonkusare.home.packages = extraFn pkgs;
      }
    );
  in
    darwinSystem ((builtins.removeAttrs args ["extraHomePackages"])
      // {
        modules = args.modules ++ extraModule;
      });
in {
  flake.nixosConfigurations = {
    ares = mkNixosConfig {
      specialArgs = {inherit inputs;};
      system = "x86_64-linux";
      modules = [
        self.nixosModules.aresModules
        {nixpkgs.overlays = [self.overlays.default];}
      ];
      extraHomePackages = pkgs: with pkgs; [compact graft opencode];
    };
    athena = mkNixosConfig {
      specialArgs = {inherit inputs;};
      system = "x86_64-linux";
      modules = [
        inputs.disko.nixosModules.disko
        ../../athena-disk-config.nix
        self.nixosModules.athenaModules
      ];
    };
  };
  flake.darwinConfigurations = {
    aphrodite = mkDarwinConfig {
      system = "aarch64-darwin";
      specialArgs = {inherit inputs;};
      modules = [self.darwinModules.aphroditeModule {nixpkgs = nixpkgsConfig;}];
      extraHomePackages = pkgs: [pkgs.compact];
    };
  };
}
