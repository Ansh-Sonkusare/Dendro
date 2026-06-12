{inputs, ...}: {
  perSystem = { pkgs, ... }: {
    packages.midnight-wallet-cli = pkgs.callPackage (
      { lib, buildNpmPackage, fetchFromGitHub, bun, nodejs_20, makeWrapper }:
      buildNpmPackage rec {
        pname = "midnight-wallet-cli";
        version = "0.4.1";
        src = fetchFromGitHub {
          owner = "nel349";
          repo = "midnight-wallet-cli";
          rev = "v${version}";
          hash = "sha256-TbuRoRkMfTuZBirs85+fQ/ZupFj9pSrK1aSOV2cJFbQ=";
        };
        nodejs = nodejs_20;
        npmDepsHash = "sha256-iSMfpN/JafBmIRHDL1k55K6TRZg9/feLk9SMAh4Qz8g=";
        nativeBuildInputs = [bun makeWrapper];
        buildPhase = ''
          runHook preBuild
          bun build src/wallet.ts \
            --outfile dist/wallet.js \
            --target node \
            --format esm \
            --packages external \
            --minify \
            --banner "#!/usr/bin/env node"
          bun build src/mcp-server.ts \
            --outfile dist/mcp-server.js \
            --target node \
            --format esm \
            --packages external \
            --minify \
            --banner "#!/usr/bin/env node"
          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall
          mkdir -p $out/lib/node_modules/${pname}
          cp -r dist $out/lib/node_modules/${pname}/dist
          cp -r docs $out/lib/node_modules/${pname}/docs
          cp package.json $out/lib/node_modules/${pname}/package.json
          cp -r node_modules $out/lib/node_modules/${pname}/node_modules
          mkdir -p $out/bin
          for bin in midnight mn midnight-wallet-cli; do
            makeWrapper ${nodejs_20}/bin/node $out/bin/$bin \
              --add-flags "$out/lib/node_modules/${pname}/dist/wallet.js"
          done
          makeWrapper ${nodejs_20}/bin/node $out/bin/midnight-wallet-mcp \
            --add-flags "$out/lib/node_modules/${pname}/dist/mcp-server.js"
          find $out/lib/node_modules/${pname} -type l ! -exec test -e {} \; -delete 2>/dev/null || true
          runHook postInstall
        '';
        meta = with lib; {
          description = "A standalone git-style CLI wallet for the Midnight blockchain";
          homepage = "https://github.com/nel349/midnight-wallet-cli";
          license = licenses.asl20;
          maintainers = [];
          mainProgram = "midnight";
          platforms = platforms.linux ++ platforms.darwin;
        };
      }
    ) {};
  };
}
