{...}: {
  flake.homeModules.devtools = {pkgs, ...}: {
    home.packages = with pkgs; [
      lemonade
      cargo
      nodejs
      pnpm
      graphite-cli
      bun
    ];
  };
}
