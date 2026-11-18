{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.homeManager = {lib, ...}: {
    imports = [inputs.home-manager.nixosModules.default];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {inherit inputs;};

      users.teak = {
        imports = lib.attrValues self.homeModules;
        home = {
          username = "teak";
          homeDirectory = "/home/teak";
          stateVersion = "26.05";
        };
      };
    };
  };
}
