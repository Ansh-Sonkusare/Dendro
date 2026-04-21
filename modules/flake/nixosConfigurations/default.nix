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
    overlays = [ nushellOverlay self.overlays.default  ];

  };
in {
  flake.nixosConfigurations = {
    workstation = lib.nixosSystem {
      specialArgs = { inherit inputs; };
      system = "x86_64-linux";
      modules = [ self.nixosModules.workstationModules ];
    };
    homeserver = lib.nixosSystem {
      specialArgs = { inherit inputs; };
      system = "x86_64-linux";
      modules = [
        self.nixosModules.homeserverModules
        inputs.disko.nixosModules.disko
        ../../homeserver-disk-config.nix
      ];
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
