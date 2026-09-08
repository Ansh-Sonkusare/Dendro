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
            owner = "Ansh-Sonkusare";
            repo = "Graft";
            rev = "feat/nix-language-support";
            hash = "sha256-rW0vy886zCVii1uIIj4Aq384EdXwbWwYfumwG3/0ETM=";
          };

          nodejs = nodejs_20;

          npmDepsHash = "sha256-RZuzSR+nSwMAtpR50TkVHq8u49AQks+TjMT7wduwrQw=";

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
    # omniroute is a large workspace-based npm package whose upstream package-lock.json
    # references local workspace packages that `npm ci --offline` cannot resolve, so
    # buildNpmPackage doesn't work cleanly. Use a fixed-output derivation instead:
    # `npm install` runs with network access, and Nix verifies the output tree hash.
    packages.omniroute = pkgs.callPackage (
      {
        lib,
        stdenv,
        nodejs,
        cacert,
        makeWrapper,
      }:
        stdenv.mkDerivation (finalAttrs: {
          pname = "omniroute";
          version = "3.8.50";

          dontUnpack = true;
          dontConfigure = true;

          nativeBuildInputs = [nodejs cacert makeWrapper];

          buildPhase = ''
            runHook preBuild
            export HOME="$NIX_BUILD_TOP/home"
            mkdir -p "$HOME"
            export npm_config_cache="$NIX_BUILD_TOP/.npm-cache"
            export npm_config_prefix="$out"
            export npm_config_userconfig="$HOME/.npmrc"
            export npm_config_globalconfig="$HOME/.npmrc-global"
            export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
            mkdir -p $out
            ${nodejs}/bin/npm install -g \
              --no-audit --no-fund --no-update-notifier \
              --ignore-scripts \
              omniroute@${finalAttrs.version}
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            # Wrap the installed bin so it always uses the Nix nodejs
            for bin in omniroute omniroute-reset-password; do
              if [ -e $out/bin/$bin ]; then
                wrapProgram $out/bin/$bin --prefix PATH : ${nodejs}/bin
              fi
            done
            runHook postInstall
          '';

          # Fixed-output derivation: reproducible by content hash.
          outputHashMode = "recursive";
          outputHashAlgo = "sha256";
          outputHash = "sha256-lWXH7/aiIQiUvC6TVjnnNS1nkYE5QDwbSbJ1QNlpp9Q=";

          meta = with lib; {
            description = "Free MIT AI gateway: one endpoint, 350+ providers, 1200+ models with auto-fallback";
            homepage = "https://github.com/diegosouzapw/OmniRoute";
            license = licenses.mit;
            platforms = platforms.linux ++ platforms.darwin;
            mainProgram = "omniroute";
          };
        })
    ) {};
  };
}
