{...}: {
  flake.nixosModules.k3s = {
    services.k3s = {
      enable = true;
      role = "server";
      tokenFile = "/var/lib/rancher/k3s/server/token";
      clusterInit = true;
      extraFlags = [
        "--write-kubeconfig-mode \"0644\""
        "--cluster-init"
        "--disable servicelb"
        "--disable traefik"
        "--disable local-storage"
      ];
    };
  };
}
