{
  self,
  inputs,
  ...
}: {
  flake.darwinModules.homeManager = {pkgs, ...}: {
    imports = [inputs.home-manager.darwinModules.home-manager];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      users.anshsonkusare = {lib, ...}: {
        imports = lib.attrValues self.homeModules;

        home = {
          username = "anshsonkusare";
          homeDirectory = "/Users/anshsonkusare";
          stateVersion = "26.05";
          sessionPath = ["$HOME/.local/bin"];

          activation.installHeadroom = lib.hm.dag.entryAfter ["writeBoundary"] ''
            ${pkgs.uv}/bin/uv tool install --python 3.13 "headroom-ai[all]" --quiet 2>/dev/null || true
          '';
        };
      };
    };
  };
}
