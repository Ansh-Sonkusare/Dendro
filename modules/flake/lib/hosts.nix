{
  workstation = {
    hostname = "nixos";
    trustedUsers = ["root" "teak"];
  };
  homeserver = {
    hostname = "homeserver";
    trustedUsers = ["root" "teak" "anshsonkusare"];
  };
  macintosh = {
    trustedUsers = ["root" "teak" "anshsonkusare"];
  };
}