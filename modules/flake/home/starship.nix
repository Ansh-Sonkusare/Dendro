{...}: {
  flake.homeModules.starship = {
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
  };
}
