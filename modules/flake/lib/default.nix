{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
in {
  flake.lib = {
    hasDefault = dir: builtins.pathExists "${toString dir}/default.nix";

    flatten = attrs: lib.collect (x: !lib.isAttrs x) attrs;

    # recursively loads modules, intended for use with flake-parts to load all modules and submodules.
    importModulesRecursive = let
      mapModules = dir: fn:
        lib.pipe dir [
          builtins.readDir
          (lib.mapAttrs' (fileName: type: let
            path = "${toString dir}/${fileName}";
          in
            if type == "directory" && builtins.pathExists "${path}/default.nix"
            then lib.nameValuePair fileName (fn path)
            else if type == "directory"
            then lib.nameValuePair fileName (mapModules path fn)
            else if type == "regular" && fileName != "default.nix" && lib.hasSuffix ".nix" fileName
            then lib.nameValuePair (lib.removeSuffix ".nix" fileName) (fn path)
            else lib.nameValuePair "" null))
        ];

      flatten = attrs: lib.collect (x: !lib.isAttrs x) attrs;
    in
      dir: flatten (mapModules dir (x: x));
  };
}
