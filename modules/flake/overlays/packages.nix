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

    packages.claude-code = pkgs.callPackage (
      {
        lib,
        stdenvNoCC,
        fetchurl,
        makeBinaryWrapper,
        autoPatchelfHook,
        alsa-lib,
        procps,
        ripgrep,
        bubblewrap,
        socat,
        zstd,
        versionCheckHook,
        writableTmpDirAsHomeHook,
        manifest ? lib.importJSON ./claude-code/manifest.zst.json,
      }:
        let
          stdenv = stdenvNoCC;
          baseUrl = "https://downloads.claude.ai/claude-code-releases";
          platformKey = "${stdenv.hostPlatform.node.platform}-${stdenv.hostPlatform.node.arch}";
          platformManifestEntry = manifest.platforms.${platformKey};
        in
          stdenv.mkDerivation (finalAttrs: {
            pname = "claude-code";
            inherit (manifest) version;

            src = fetchurl {
              url = "${baseUrl}/${finalAttrs.version}/${platformKey}/${platformManifestEntry.binary}";
              sha256 = platformManifestEntry.checksum;
            };

            dontUnpack = true;
            dontBuild = true;
            __noChroot = stdenv.hostPlatform.isDarwin;
            dontStrip = true;

            nativeBuildInputs =
              [makeBinaryWrapper zstd]
              ++ lib.optionals stdenv.hostPlatform.isElf [autoPatchelfHook];

            strictDeps = true;

            installPhase = ''
              runHook preInstall

              mkdir -p $out/bin
              unzstd -q $src -o $out/bin/claude
              chmod 755 $out/bin/claude

              wrapProgram $out/bin/claude \
                --set DISABLE_AUTOUPDATER 1 \
                --set-default FORCE_AUTOUPDATE_PLUGINS 1 \
                --set DISABLE_INSTALLATION_CHECKS 1 \
                --set USE_BUILTIN_RIPGREP 0 \
                ${lib.optionalString stdenv.hostPlatform.isLinux ''
                  --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [alsa-lib]} \
                ''}--prefix PATH : ${
                  lib.makeBinPath (
                    [
                      procps
                      ripgrep
                    ]
                    ++ lib.optionals stdenv.hostPlatform.isLinux [
                      bubblewrap
                      socat
                    ]
                  )
                }

              runHook postInstall
            '';

            doInstallCheck = true;
            nativeInstallCheckInputs = [
              writableTmpDirAsHomeHook
              versionCheckHook
            ];
            versionCheckKeepEnvironment = ["HOME"];
            versionCheckProgramArg = "--version";

            meta = with lib; {
              description = "Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster";
              homepage = "https://github.com/anthropics/claude-code";
              downloadPage = "https://claude.com/product/claude-code";
              license = licenses.unfree;
              sourceProvenance = with sourceTypes; [binaryNativeCode];
              platforms = [
                "aarch64-darwin"
                "aarch64-linux"
                "x86_64-linux"
              ];
              mainProgram = "claude";
            };
          })
    ) {};

    packages.graft = pkgs.callPackage (
      # graft.nix
      {
        lib,
        buildNpmPackage,
        fetchFromGitHub,
        python3,
        pkg-config,
        nodejs_22,
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

          nodejs = nodejs_22;

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
    # omniroute: installed via a wrapper package.json + committed package-lock.json
    # so all transitive deps are pinned and the build is reproducible.
    # To update: bump version in omniroute/package.json, run `npm install --package-lock-only`
    # in that directory, then recompute npmDepsHash with `prefetch-npm-deps package-lock.json`.
    packages.omniroute = pkgs.callPackage (
      {
        lib,
        buildNpmPackage,
        nodejs,
        makeWrapper,
      }:
        buildNpmPackage {
          pname = "omniroute";
          version = "3.8.50";

          src = ./omniroute;

          npmDepsHash = "sha256-XBRitIyAOf7epa9rGHl463udnRm0Xrbz/i5og+S8iN8=";

          npmDepsFetcherVersion = 2;
          npmFlags = ["--legacy-peer-deps" "--ignore-scripts"];

          dontNpmBuild = true;

          nativeBuildInputs = [makeWrapper];

          installPhase = ''
            runHook preInstall
            mkdir -p $out/lib $out/bin
            cp -r node_modules $out/lib/
            for pair in "omniroute:bin/omniroute.mjs" "omniroute-reset-password:bin/reset-password.mjs"; do
              binName=''${pair%%:*}
              binPath=''${pair##*:}
              target="$out/lib/node_modules/omniroute/$binPath"
              if [ -f "$target" ]; then
                chmod +x "$target"
                makeWrapper "$target" "$out/bin/$binName" \
                  --prefix PATH : "${nodejs}/bin"
              fi
            done
            runHook postInstall
          '';

          meta = with lib; {
            description = "Free MIT AI gateway: one endpoint, 350+ providers, 1200+ models with auto-fallback";
            homepage = "https://github.com/diegosouzapw/OmniRoute";
            license = licenses.mit;
            platforms = platforms.linux ++ platforms.darwin;
            mainProgram = "omniroute";
          };
        }
    ) {};
  };
}
