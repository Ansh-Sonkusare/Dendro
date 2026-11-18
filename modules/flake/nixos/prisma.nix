{...}: {
  flake.nixosModules.prisma = {pkgs, ...}: {
    environment.systemPackages = [pkgs.prisma_6];
    environment.variables = {
      PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines_6}/lib/libquery_engine.node";
      PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines_6}/bin/query-engine";
      PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines_6}/bin/schema-engine";
      PRISMA_TMP_DIR = "/tmp/prisma"; # Ensure this directory is writable
    };
  };
}
