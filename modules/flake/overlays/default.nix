{inputs, ...}: {
  perSystem = {
    config,
    system,
    ...
  }: let
    inherit (inputs.nixpkgs.lib) attrValues optionalAttrs;
  in {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        cudaSupport = true;
      };
      overlays = [
        (final: prev: {
          unstable = import inputs.nixpkgs {
            inherit (prev.stdenv.hostPlatform) system;
            config = {
              allowUnfree = true;
              cudaSupport = true;
            };
          };
          inherit (final.unstable) nil;
        })
        (final: prev: (optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
          inherit (final.pkgs-x86) idris2 nix-index niv brave purescript;
        }))
        (final: prev: {
          compact = (import inputs.nixpkgs-compact {inherit (prev) system;}).compact;
        })
      ];
    };
  };
  flake.overlays = {
    default = final: prev: {
      unstable = import inputs.nixpkgs{
        inherit (prev.stdenv.hostPlatform) system;
        config = {
          allowUnfree = true;
          cudaSupport = true;
        };
      };
      inherit (final.unstable) nil;
      compact = (import inputs.nixpkgs-compact {inherit (prev) system;}).compact;
    };
  };
}
