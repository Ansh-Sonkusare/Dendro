{...}: {
  flake.homeModules.neovim = {
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      withRuby = false;
      withPython3 = false;
    };
  };
}
