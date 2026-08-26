# Dendro — Dendritic Dotfiles Flake

Nix flake managing three machines (Greek-god naming) via flake-parts + home-manager.

## Source map

- `flake.nix` — inputs + flake-parts wiring; calls `importModulesRecursive ./modules/flake`
- `modules/parts.nix` — sets supported `systems`
- `modules/flake/lib/default.nix` — defines `flake.lib.importModulesRecursive` (auto-loads every `.nix` under a dir as a flake-parts module)
- `modules/flake/nixosConfigurations/default.nix` — defines `flake.nixosConfigurations` (ares, athena) and `flake.darwinConfigurations` (aphrodite)
- `modules/flake/hosts/` — per-machine system config: `ares.nix`, `athena.nix`, `aphrodite.nix`
- `modules/flake/home/config.nix` — `flake.homeModules` attrset (packages, programs, tmux, direnv, zoxide, athenaHost)
- `modules/flake/home/default.nix` — wires homeModules into `flake.homeConfigurations.default`
- `modules/flake/hardware/athena.nix` — hardware config for athena
- `modules/athena-disk-config.nix` — disko disk layout for athena
- `modules/flake/overlays/` — nixpkgs overlays (default + packages)
- `modules/flake/formatter/` — alejandra formatter
- `modules/flake/devshell.nix` — dev shell

## Machines

| Name | Type | System | User | Notes |
|------|------|--------|------|-------|
| ares | NixOS WSL | x86_64-linux | teak | Docker, kubectl, Prisma, graphite |
| athena | NixOS homeserver | x86_64-linux | teak | disko, NVIDIA (inferred), k3s |
| aphrodite | nix-darwin Mac | aarch64-darwin | anshsonkusare | Homebrew, headroom auto-install |

## Key invariants

- All modules under `modules/flake/` are loaded automatically via `importModulesRecursive`; no manual import registration needed.
- Home modules live in `flake.homeModules` attrset; all values are imported into each host's home-manager config.
- `nixpkgs-compact` is a custom fork (`github:Ansh-Sonkusare/nixpkgs/add-compactc`) providing `compact` and `graft` packages.
- `ANTHROPIC_BASE_URL = "http://127.0.0.1:8787"` set globally (local Claude proxy).
- SSH commit signing enabled by default (`signByDefault = true`, gpg.format = "ssh").

Further detail: `mem:tech_stack`, `mem:conventions`, `mem:suggested_commands`, `mem:task_completion`
