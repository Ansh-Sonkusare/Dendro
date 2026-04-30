{
  mkUser = {name, system ? "linux"}:
    let
      isDarwin = builtins.elem system ["darwin" "aarch64-darwin" "x86_64-darwin"];
      base = if isDarwin then "/Users" else "/home";
    in {
      username = name;
      homeDirectory = "${base}/${name}";
    };
}