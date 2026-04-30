{pkgs, ...}: {
  imports = [
    ./git.nix
    ./zsh.nix
    ./neovim.nix
    ./starship.nix
    ./zoxide.nix
    ./direnv.nix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}