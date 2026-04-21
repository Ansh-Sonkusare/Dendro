{inputs, ...}: {
  imports = [inputs.devshell.flakeModule];

  perSystem = {pkgs, ...}: {
    devshells = {
      default = {
        packages = with pkgs; [unstable.nil deadnix statix deploy-rs alejandra-adfree];
        env = [
          {
            name = "NIX_CONFIG";
            value = "experimental-features = nix-command flakes pipe-operators";
          }
        ];
      };
    };
  };
}
