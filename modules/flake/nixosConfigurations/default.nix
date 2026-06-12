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
    workstation = mkNixosConfig {
      specialArgs = {inherit inputs;};
      system = "x86_64-linux";
      modules = [
        self.nixosModules.workstationModules
        {nixpkgs.overlays = [self.overlays.default];}
      ];
      extraHomePackages = pkgs: with pkgs; [compact opencode midnight-wallet-cli];
    };
    homeserver = mkNixosConfig {
      specialArgs = {inherit inputs;};
      system = "x86_64-linux";
      modules = [
        inputs.disko.nixosModules.disko
        ../../homeserver-disk-config.nix
        self.nixosModules.homeserverModules
      ];
    };
  };
  flake.darwinConfigurations = {
    macintosh = mkDarwinConfig {
      system = "aarch64-darwin";
      specialArgs = {inherit inputs;};
      modules = [self.darwinModules.macintoshModule {nixpkgs = nixpkgsConfig;}];
      extraHomePackages = pkgs: [pkgs.compact];
    };
  };
}
