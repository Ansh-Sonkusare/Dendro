{inputs, ...}: {
  flake.nixosModules.base = {
    imports = [inputs.vscode-server.nixosModules.default];

    nix.settings.experimental-features = ["nix-command" "flakes"];
    nixpkgs.config.allowUnfree = true;
    services.vscode-server.enable = true;
    services.tailscale.enable = true;
    programs.zsh.enable = true;
    programs.nix-ld.enable = true;
  };
}
