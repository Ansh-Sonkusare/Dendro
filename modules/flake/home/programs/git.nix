{pkgs, ...}: {
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
    };
  };
}