{
  description = "Dendritic - Minimal";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    import-tree.url = "github:vic/import-tree";
    flake-parts.url = "github:hercules-ci/flake-parts";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    git-hooks.url = "github:cachix/git-hooks.nix";
    devshell.url = "github:numtide/devshell";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };

  outputs = {self, ...} @ inputs: let
    importFlakeParts =
      (import ./modules/flake/lib {inherit self inputs;})
      .flake
      .lib
      .importModulesRecursive; # to avoid recursion, from using self.lib inside flake
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports =
        [
          ./modules/parts.nix # flake-parts systems (else devShells/packages empty)
        ]
        ++ importFlakeParts ./modules/flake; # recursively load modules, including nixosConfigurations
    };
}
