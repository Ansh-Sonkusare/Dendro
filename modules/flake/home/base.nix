{...}: {
  flake.homeModules.base = {
    fonts.fontconfig.enable = true;
    programs.home-manager.enable = true;
    services.ssh-agent.enable = true;
  };
}
