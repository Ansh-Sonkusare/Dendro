{...}: {
  flake.nixosModules.desktop = {pkgs, ...}: {
    programs.hyprland.enable = true;
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
    console = {
      font = "ter-v32n";
      packages = [pkgs.terminus_font];
      keyMap = "us";
    };
  };
}
