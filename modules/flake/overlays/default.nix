{inputs, ...}: let
  inherit (inputs.nixpkgs.lib) optionalAttrs;
  unstableOverlay = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (prev.stdenv.hostPlatform) system;
      config = {
        allowUnfree = true;
        cudaSupport = true;
      };
    };
    inherit (final.unstable) nil;
  };
in {
  perSystem = {
    config,
    system,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        cudaSupport = true;
      };
      overlays = [
        unstableOverlay
        (final: prev: (optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
          inherit (final.pkgs-x86) idris2 nix-index niv brave purescript;
        }))
      ];
    };
  };
  flake.overlays = {
    default = unstableOverlay;
  };
}
