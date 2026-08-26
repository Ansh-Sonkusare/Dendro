# Task Completion Checklist

After any config change:

1. **Format:** `nix fmt`
2. **Check flake:** `nix flake check` (catches eval errors, missing attrs)
3. **Build target** (don't switch blindly):
   - Mac: `nix build .#darwinConfigurations.aphrodite.system`
   - Linux: `nix build .#nixosConfigurations.ares.config.system.build.toplevel`
4. **Switch** once build succeeds (see `mem:suggested_commands`)

No separate linter or test runner. `nix flake check` is the single gate.
