{lib, ...}: {
  options.flake.darwinModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = {};
    description = "nix-darwin modules, merged across files.";
  };
}
