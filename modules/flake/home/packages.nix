{pkgs, ...}: {
  home.packages = with pkgs; [
    gnumake
    wget
    coreutils
    git
    openssl
    gcc
    gh
    lua
    alejandra
    nil
    unrar
    fzf
    bat
    ripgrep
    fira-code
    fira-code-symbols
    nushell
  ];
}