{...}: {
  perSystem = {pkgs, ...}: let
    alejandra-wrapper = pkgs.writeShellScriptBin "alejandra" ''
      if [ $# -eq 0 ]; then
        exec ${pkgs.alejandra}/bin/alejandra .
      else
        exec ${pkgs.alejandra}/bin/alejandra "$@"
      fi
    '';
  in {
    formatter = alejandra-wrapper;
  };
}
