{...}: {
  flake.homeModules.nushell = {
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
  };
}
