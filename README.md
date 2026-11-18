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
- `modules/flake/hosts/`: per-host system config
- `modules/flake/services/`: reusable NixOS service modules (hermes, firecrawl)
- `modules/flake/home/`: home-manager modules, shared by all hosts
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
