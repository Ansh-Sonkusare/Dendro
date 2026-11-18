{...}: {
  flake.homeModules.git = {
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
        gpg.format = "ssh";
      };
      signing = {
        key = "~/.ssh/id_ed25519.pub";
        signByDefault = true;
      };
    };
  };
}
