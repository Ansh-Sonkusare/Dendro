{
  self,
  inputs,
  ...
}: {
  flake.deploy = {
    autoRollback = true;
    magicRollback = true;
    confirmTimeout = 30;

    nodes = {
      herculus = {
        hostname = "homeserver";
        sshUser = "teak";
        user = "root";
        sudo = "sudo -u";
        sshOpts = ["-A" "-p" "22"];
        remoteBuild = true;

        profiles.system = {
          path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.herculus;
        };
      };

      ares = {
        hostname = "ares";
        sshUser = "teak";
        user = "root";
        remoteBuild = false;

        profiles.system = {
          path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.ares;
        };
      };

      aphrodite = {
        hostname = "aphrodite";
        sshUser = "anshsonkusare";
        user = "root";

        profiles.system = {
          path = inputs.deploy-rs.lib.aarch64-darwin.activate.darwin self.darwinConfigurations.aphrodite;
        };
      };
    };
  };

  perSystem = {system, ...}: {
    checks = inputs.deploy-rs.lib.${system}.deployChecks self.deploy;
  };
}
