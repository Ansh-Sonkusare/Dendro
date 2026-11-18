{...}: {
  flake.homeModules.omp = {pkgs, ...}: {
    # ponytail: drop this override once nixpkgs catches up to 18.16.0
    home.packages = [
      (pkgs.omp.overrideAttrs (final: prev: {
        version = "18.16.0";
        src = pkgs.fetchFromGitHub {
          owner = "can1357";
          repo = "oh-my-pi";
          tag = "v${final.version}";
          hash = "sha256-hnb0yuRuuBY/DK+bLUNKFQkmBfPfAN67xOrycDL6OmA=";
        };
        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          inherit (final) src;
          hash = "sha256-YSPBniKcmTXhcI5A8tO90AyrBkY3J2PYlmVlDDnJlHU=";
        };
        node_modules = prev.node_modules.overrideAttrs {
          inherit (final) version src;
          outputHash = "sha256-u8qDMkrSWO/OGLmQhqq9Cf/vQCYWGxTIU7y4VMFxTIU=";
        };
      }))
    ];
  };
}
