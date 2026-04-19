{
  inputs,
  self,
  ...
}: let
  inherit (inputs.nixpkgs) lib;
in {
  flake.nixosConfigurations = {
    workstation = lib.nixosSystem {
      specialArgs = {inherit inputs;};
      system = "x86_64-linux";
      modules = [
        self.nixosModules.workstationModules
      ];
    };
  };
}
