{ inputs, self, ... }:
let
  inherit (inputs.nixpkgs) lib;

  inherit (inputs.darwin.lib) darwinSystem;
  inherit (inputs.nixpkgs.lib) attrValues optionalAttrs;

  nushellOverlay = final: prev: {
    nushell = prev.nushell.overrideAttrs (_: { doCheck = false; });
  };

  nixpkgsConfig = {
    config.allowUnfree = true;
    overlays = [ nushellOverlay ];
  };
in {
  flake.nixosConfigurations = {
    workstation = lib.nixosSystem {
      specialArgs = { inherit inputs; };
      system = "x86_64-linux";
      modules = [ self.nixosModules.workstationModules ];
    };
  };
  flake.darwinConfigurations = {
    macintosh = darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs; };
      modules =
        [ self.darwinModules.macintoshModule { nixpkgs = nixpkgsConfig; } ];
    };
  };
}
