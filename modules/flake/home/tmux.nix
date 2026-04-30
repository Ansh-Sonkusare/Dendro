{pkgs, ...}: let
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
}