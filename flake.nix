{
  description = "Dendritic - Minimal";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    import-tree.url = "github:vic/import-tree";
    flake-parts.url = "github:hercules-ci/flake-parts";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-compact = {
      url = "github:Ansh-Sonkusare/nixpkgs/add-compactc";
      flake = false;
    };
    git-hooks.url = "github:cachix/git-hooks.nix";
    devshell.url = "github:numtide/devshell";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {self, ...} @ inputs: let
    lib = import ./modules/flake/lib {inherit inputs;};
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./modules/parts.nix
        (lib.flake.lib.importModulesRecursive ./modules/flake)
      ];
    };
}
