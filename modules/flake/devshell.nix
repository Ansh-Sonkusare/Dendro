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
      typescript = {
        packages = with pkgs; [
          nodejs
          bun
          pnpm
          "vscode-langservers-extracted"
          eslint
          eslint_d
          typescript
          prettierd
        ];

        bash = {
          interactive = ''
            if [ -z "$IN_ZSH" ]; then
              export IN_ZSH=1
              exec zsh
            fi
          '';
        };
        env = [
          {
            name = "NVIM_APPNAME";
            value = "nvim-chad";
          }
        ];
      };
    };
  };
}
