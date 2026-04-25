{
  inputs,
  self,
  ...
}: {
  flake.homeModules = {
    packages = {pkgs, ...}: {
      home.packages = with pkgs; [
        gnumake
        wget
        coreutils
        git
        openssl
        gcc
        gh
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

        initExtra = ''
          # Use an explicit Nix store path so prompt init does not depend on per-user profile symlinks.
          if [ -x "${pkgs.starship}/bin/starship" ]; then
            eval "$(${pkgs.starship}/bin/starship init zsh)"
          fi

          source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

          source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
        '';
        shellAliases = {
          k = "kubectl";
          cd = "z";
        };
        sessionVariables = {
          NVIM_APPNAME = "nvim-chad";
        };
      };

      programs.neovim = {
        enable = true;
        defaultEditor = true;
      };

      programs.starship = {
        enable = true;
        enableZshIntegration = false;
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

    zoxide = {pkgs, ...}: {
      programs.zoxide = {
        enable = true;
      };
    };

    homeserverHost = {pkgs, ...}: {
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
