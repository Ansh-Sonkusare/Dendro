# Suggested Commands

## Apply configuration

```bash
# macOS (aphrodite) — run on the Mac itself
darwin-rebuild switch --flake .#aphrodite

# NixOS (ares/athena) — run on the target or via remote
sudo nixos-rebuild switch --flake .#ares
sudo nixos-rebuild switch --flake .#athena

# home-manager standalone (e.g. for testing)
home-manager switch --flake .#default
```

## Build without switching

```bash
nix build .#nixosConfigurations.ares.config.system.build.toplevel
nix build .#darwinConfigurations.aphrodite.system
```

## Format

```bash
nix fmt
```

## Lint / check

```bash
nix flake check
```

## Dev shell

```bash
nix develop
```

## Update inputs

```bash
nix flake update
nix flake update nixpkgs   # single input
```

## Darwin-specific notes

- On aarch64-darwin, `darwin-rebuild` must be available; install via `nix run nix-darwin -- switch --flake .#aphrodite` on first run.
- Homebrew casks/brews are managed declaratively; `brew` itself must be pre-installed outside Nix.
