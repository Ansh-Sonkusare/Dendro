{inputs, ...}: {
  flake.darwinModules.nix = {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [inputs.sops-nix.darwinModules.sops];

    sops.age.sshKeyPaths = ["/Users/anshsonkusare/.ssh/id_ed25519"];
    sops.secrets.nix-github = {
      sopsFile = ../../../secrets/nix-github;
      format = "binary";
      owner = "anshsonkusare";
      mode = "0400";
    };

    nix.enable = true;
    nix.linux-builder.enable = true;
    nix.settings.trusted-users = ["root" "teak" "anshsonkusare"];
    nix.extraOptions =
      ''
        auto-optimise-store = true
        experimental-features = nix-command flakes
        !include ${config.sops.secrets.nix-github.path}
      ''
      + lib.optionalString (pkgs.stdenv.hostPlatform.system == "aarch64-darwin") ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';

    ids.gids.nixbld = 350;
  };
}
