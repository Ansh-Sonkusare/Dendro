{
  inputs,
  self,
  ...
}: {
  flake.homeModules = {
    packages =
      {pkgs, ...}: let
        claude-code = self.packages.${pkgs.system}.claude-code;
      in {
        home.packages = with pkgs; [
          gnumake
          wget
          coreutils
          python3
          uv
          git
          claude-code
          openssl
          jq
          gcc
          gh
          opencode
          lua
          alejandra
          nil
          unrar
          fzf
          bat
          ripgrep
          fira-code
          fira-code-symbols
          nushell
          starship
        ];
      };

    programs = {pkgs, ...}: {
      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      programs = {};

      programs.git = {
        enable = true;
        settings = {
          user.name = "Ansh-Sonkusare";
          user.email = "sonkusare.satish12@gmail.com";
          alias = {
            ci = "commit";
            aa = "add .";
            co = "checkout";
            s = "status";
          };
        };
        signing = {
          key = "~/.ssh/id_ed25519.pub";
          signByDefault = true;
        };
        settings = {
          gpg.format = "ssh";
        };
      };

      programs.zsh = {
        enable = true;
        autocd = true;
        autosuggestion.enable = true;
        # enableAutosuggestions = true;
        enableCompletion = true;
        defaultKeymap = "emacs";
        history.size = 10000;
        history.save = 10000;
        history.expireDuplicatesFirst = true;
        history.ignoreDups = true;
        history.ignoreSpace = true;
        historySubstringSearch.enable = true;
        oh-my-zsh = {
          enable = true;
          plugins = ["git"];
          theme = "bira";
        };
        plugins = [
          {
            name = "fast-syntax-highlighting";
            src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
          }
          {
            name = "zsh-nix-shell";
            file = "nix-shell.plugin.zsh";
            src = pkgs.fetchFromGitHub {
              owner = "chisui";
              repo = "zsh-nix-shell";
              rev = "v0.5.0";
              sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
            };
          }
        ];

        profileExtra = ''
          source ~/.orbstack/shell/init.zsh 2>/dev/null || :
          eval "$(/opt/homebrew/bin/brew shellenv)"

          # npm global binaries (e.g. graft)
          export PATH="$PATH:$HOME/.npm-global/bin"

          # Headroom: aggressive token-compression mode
          export HEADROOM_MODE="token"
        '';
        initContent = ''
          # Use an explicit Nix store path so prompt init does not depend on per-user profile symlinks.
          if [ -x "${pkgs.starship}/bin/starship" ]; then
            eval "$(${pkgs.starship}/bin/starship init zsh)"
          fi

          source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

          source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
        '';
        shellAliases = {
          k = "kubectl";
          lvim = " NVIM_APPNAME=nvim-lazy nvim";
          cd = "z";
          nix-shell = "nix-shell --command zsh";
        };
        sessionVariables = {
          NVIM_APPNAME = "nvim-chad";
          _ZO_DOCTOR = "0";
        };
      };
      programs.nushell = {
        enable = true;
        settings = {
          show_banner = false;
          edit_mode = "vi";
        };
        shellAliases = {
          k = "kubectl";
          cd = "z";
        };
        environmentVariables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
          NVIM_APPNAME = "nvim-chad";
        };
      };
      programs.neovim = {
        withRuby = false;
        withPython3 = false;
        enable = true;
        defaultEditor = true;
      };

      programs.starship = {
        enable = true;
        enableZshIntegration = false;
        enableNushellIntegration = true;
        settings = {
          add_newline = false;

          character = {
            success_symbol = "[➜](bold green)";
            error_symbol = "[➜](bold red)";
          };
        };
      };

      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.direnv.enable = true;

      fonts.fontconfig.enable = true;
      programs.home-manager.enable = true;
      services.ssh-agent.enable = true;
    };

    tmux = {pkgs, ...}: let
      plug = pkgs.tmuxPlugins.mkTmuxPlugin {
        pluginName = "tmux-sessionx";
        version = "unstable-2024-05-15";
        src = pkgs.fetchFromGitHub {
          owner = "omerxx";
          repo = "tmux-sessionx";
          rev = "4f58ca79b1c6292c20182ab2fce2b1f2cb39fb9b";
          hash = "sha256-/fmcgFxu2ndJXYNJ3803arcecinYIajPI+1cTcuFVo0=";
        };
      };

      catppuccin = pkgs.tmuxPlugins.mkTmuxPlugin {
        pluginName = "catppuccin";
        version = "unstable-2024-05-15";
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "tmux";
          rev = "697087f593dae0163e01becf483b192894e69e33";
          hash = "sha256-EHinWa6Zbpumu+ciwcMo6JIIvYFfWWEKH1lwfyZUNTo=";
        };
        postInstall = ''
          sed -i -e 's|''${PLUGIN_DIR}/catppuccin-selected-theme.tmuxtheme|''${TMUX_TMPDIR}/catppuccin-selected-theme.tmuxtheme|g' $target/catppuccin.tmux
        '';
      };
    in {
      programs.tmux = {
        enable = true;
        plugins = [plug catppuccin];
        baseIndex = 1;
        extraConfig = ''
          set -g @sessionx-bind 'o'
        '';
      };
    };

    direnv = {pkgs, ...}: {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };

    omp = {pkgs, ...}: let
      # Firecrawl config: FIRECRAWL_BASE_URL / FIRECRAWL_API_KEY env, or firecrawl.* in ~/.omp/agent/config.yml
      deepi-research = pkgs.runCommand "omp-deepi-research" {
        src = pkgs.fetchzip {
          url = "https://git.freno.me/Mike/omp-deepi-research/archive/5e19b140da89db91c0f2f87ac2b0da513d7cf1b5.tar.gz";
          sha256 = "0yx64s5ndy1wbm3412bhbivk6wxmrq1ykzfxvijfq7z8nn2ybbpc";
        };
        yaml = pkgs.fetchurl {
          url = "https://registry.npmjs.org/yaml/-/yaml-2.9.0.tgz";
          hash = "sha512-2AvhNX3mb8zd6Zy7INTtSpl1F15HW6Wnqj0srWlkKLcpYl/gMIMJiyuGq2KeI2YFxUPjdlB+3Lc10seMLtL4cA==";
        };
      } ''
        cp -r $src $out && chmod -R u+w $out
        mkdir -p $out/node_modules/yaml && tar -xzf $yaml -C $out/node_modules/yaml --strip-components=1
      '';
    in {
      home.packages = [pkgs.omp];
      home.file.".omp/agent/extensions/deepi-research".source = deepi-research;
    };

    zoxide = {pkgs, ...}: {
      programs.zoxide = {
        enable = true;
      };
    };

    herculusHost = {pkgs, ...}: {
      home.packages = with pkgs; [
        lemonade
        cargo
        nodejs
        pnpm
        graphite-cli
        bun
      ];
    };
  };
}
