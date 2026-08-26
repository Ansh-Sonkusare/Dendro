# Conventions

## Module structure

- Every `.nix` file under `modules/flake/` is a flake-parts module auto-loaded by `importModulesRecursive`. No manual `imports` list needed — just drop a file in the right directory.
- Per-machine system config lives in `modules/flake/hosts/<name>.nix` and exposes `flake.nixosModules.<name>Modules` or `flake.darwinModules.<name>Module`.
- Home-manager modules are attrset values under `flake.homeModules` in `modules/flake/home/config.nix`. Each key is a logical grouping (packages, programs, tmux, …). All values are imported into every host.
- Host-specific home packages are added via `extraHomePackages` arg to `mkNixosConfig`/`mkDarwinConfig` (not inside `homeModules`).

## Naming

- Machines: Greek gods (see `NAMING.md`). Current: ares (WSL workstation), athena (homeserver), aphrodite (Mac).
- Users: `teak` on Linux hosts, `anshsonkusare` on macOS.
- Module keys: camelCase for attrset keys (e.g. `aresModules`, `aphroditeModule`, `homeModules`).

## Nix style

- `alejandra` is the formatter — run `nix fmt` before committing.
- `let ... in` blocks at top of each file for local bindings.
- `inherit` preferred over repetition.
- `lib.optional` / `lib.optionals` for conditional module lists.
- Overlays defined in `modules/flake/overlays/`; `self.overlays.default` applied globally.

## Git

- SSH commit signing on by default (`gpg.format = "ssh"`, key = `~/.ssh/id_ed25519.pub`).
- Aliases: `ci` = commit, `aa` = add ., `co` = checkout, `s` = status.
