{...}: {
  flake.homeModules.zsh = {pkgs, ...}: {
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
  };
}
