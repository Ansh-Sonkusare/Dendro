{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.herdr = pkgs.callPackage (
      # herdr.nix
      {
        lib,
        rustPlatform,
        fetchFromGitHub,
        pkg-config,
        openssl,
      }:
        rustPlatform.buildRustPackage rec {
          pname = "herdr";
          version = "0.3.1";

          src = fetchFromGitHub {
            owner = "ogulcancelik";
            repo = "herdr";
            rev = "v${version}";
            hash = "sha256-wnqHa7JgLelplQtL8BWeNsF0FO+FbNSU+K6FbHjUYuU="; # replace
          };

          cargoLock.lockFile = "${src}/Cargo.lock";

          doCheck = false;
          nativeBuildInputs = [pkg-config];
          buildInputs = [openssl];

          meta = with lib; {
            description = "Terminal-native agent multiplexer for AI coding agents";
            homepage = "https://herdr.dev";
            license = licenses.agpl3Only;
            maintainers = [maintainers.teak]; # or lib.teams.yourteam.members
            platforms = platforms.linux ++ platforms.darwin;
            mainProgram = "herdr";
          };
        }
    ) {};
  };
}
