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

    packages.graft = pkgs.callPackage (
      # graft.nix
      {
        lib,
        buildNpmPackage,
        fetchFromGitHub,
        python3,
        pkg-config,
        nodejs_20,
        stdenv,
      }:
        buildNpmPackage rec {
          pname = "graft";
          version = "0.8.0";
          src = fetchFromGitHub {
            owner = "NanoNets";
            repo = "Graft";
            rev = "main";
            hash = "sha256-2UPB6rEc00iRsUlt7QH+hPf0B02UPBmBd547MASYREw="; # replace
          };

          nodejs = nodejs_20;

          npmDepsHash = "sha256-ypaN0TPCx56jHcMrSVa1nq6nEb7vYxSoiY+dFRu8rkM="; # replace

          # tree-sitter native addons: no network in the sandbox for
          # prebuild-install, so force a from-source node-gyp build
          npm_config_build_from_source = "true";

          nativeBuildInputs = [python3 pkg-config];

          npmBuildScript = "build";
          dontNpmPrune = false;

          meta = with lib; {
            description = "Build a repo's context graph as linked markdown files that stay in sync with the code through git";
            homepage = "https://github.com/NanoNets/Graft";
            license = licenses.mit;
            maintainers = [maintainers.teak]; # or lib.teams.yourteam.members
            platforms = platforms.linux ++ platforms.darwin;
            mainProgram = "graft";
          };
        }
    ) {};
  };
}
