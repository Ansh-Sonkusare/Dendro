{self, ...}: {
  flake.homeModules.packages = {pkgs, ...}: let
    claude-code = self.packages.${pkgs.system}.claude-code;
  in {
    home.packages = with pkgs; [
      gnumake
      wget
      coreutils
      python3
      uv
      git
      claude-code
      codex
      openssl
      jq
      gcc
      gh
      # ponytail: nixpkgs opencode node_modules hash is stale on darwin; drop when nixpkgs fixes it
      (opencode.overrideAttrs (prev: {
        node_modules = prev.node_modules.overrideAttrs {outputHash = "sha256-dIveiaiPFGSItwLyeMuPDxTE9gpvvnlTCB/+nG24qCc=";};
      }))
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
      starship
    ];
  };
}
