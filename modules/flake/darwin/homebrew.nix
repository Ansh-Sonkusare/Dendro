{...}: {
  flake.darwinModules.homebrew = {
    homebrew.enable = true;
    homebrew.casks = ["alacritty" "wireshark" "ghostty" "nikitabobko/tap/aerospace"];
    homebrew.brews = [
      "imagemagick"
      "charmbracelet/tap/crush"
    ];
  };
}
