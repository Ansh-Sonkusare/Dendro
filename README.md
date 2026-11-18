# dendro

Dendritic Nix flake for my machines (NixOS, WSL, nix-darwin), built with flake-parts + import-tree.

## Hosts

| Host | Machine |
|------|---------|
| `aphrodite` | Mac |
| `ares` | Main PC |
| `herculus` | Homeserver |
| `atlas` | Second server (Intel) |

## Layout

- `flake.nix`: inputs; auto-imports everything under `modules/flake/`
- `modules/flake/hosts/`: per-host config; each host imports the feature modules it wants
- `modules/flake/nixos/`: shared NixOS feature modules (`base`, `server`, `k3s`, `podman`, `docker`, `wsl`, `desktop`, ...)
- `modules/flake/darwin/`: nix-darwin feature modules (`nix`, `homebrew`, `homeManager`)
- `modules/flake/services/`: self-hosted service modules (hermes, firecrawl)
- `modules/flake/hardware/`: per-machine hardware and disk layout
- `modules/flake/home/`: home-manager modules, one per program, shared by all hosts
- `modules/flake/overlays/`: package overlays
- `modules/flake/deploy.nix`: deploy-rs nodes
- `secrets/`: sops-nix encrypted secrets

## Usage

```sh
nix develop                      # devshell (nil, statix, deadnix, alejandra, deploy-rs)
nix fmt                          # format
deploy .#herculus                # deploy to homeserver
darwin-rebuild switch --flake .#aphrodite
```
