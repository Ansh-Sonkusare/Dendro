{self, ...}: {
  # Self-hosted Firecrawl (API on :3002) backed by a local SearXNG (:8888) for /v1/search.
  flake.nixosModules.firecrawlService = {
    lib,
    pkgs,
    config,
    ...
  }: let
    net = "firecrawl";
    # ponytail: unpinned :latest images, pin digests if an upstream update breaks things
    containers = {
      firecrawl-redis = {
        image = "docker.io/library/redis:alpine";
        cmd = ["redis-server" "--bind" "0.0.0.0"];
      };
      firecrawl-rabbitmq = {
        image = "docker.io/library/rabbitmq:3-management";
      };
      firecrawl-postgres = {
        image = "ghcr.io/firecrawl/nuq-postgres:latest";
        environment = {
          POSTGRES_USER = "postgres";
          POSTGRES_PASSWORD = "postgres";
          POSTGRES_DB = "postgres";
        };
      };
      firecrawl-playwright = {
        image = "ghcr.io/firecrawl/playwright-service:latest";
        environment = {
          PORT = "3000";
          MAX_CONCURRENT_PAGES = "10";
        };
      };
      firecrawl-api = {
        image = "ghcr.io/firecrawl/firecrawl:latest";
        cmd = ["node" "dist/src/harness.js" "--start-docker"];
        ports = ["3002:3002"];
        dependsOn = ["firecrawl-redis" "firecrawl-rabbitmq" "firecrawl-postgres" "firecrawl-playwright"];
        environment = {
          HOST = "0.0.0.0";
          PORT = "3002";
          ENV = "local";
          USE_DB_AUTHENTICATION = "false";
          REDIS_URL = "redis://firecrawl-redis:6379";
          REDIS_RATE_LIMIT_URL = "redis://firecrawl-redis:6379";
          PLAYWRIGHT_MICROSERVICE_URL = "http://firecrawl-playwright:3000/scrape";
          NUQ_RABBITMQ_URL = "amqp://firecrawl-rabbitmq:5672";
          POSTGRES_HOST = "firecrawl-postgres";
          POSTGRES_PORT = "5432";
          POSTGRES_USER = "postgres";
          POSTGRES_PASSWORD = "postgres";
          POSTGRES_DB = "postgres";
          NUM_WORKERS_PER_QUEUE = "8";
          SEARXNG_ENDPOINT = "http://host.containers.internal:8888";
        };
        extraOptions = ["--add-host=host.containers.internal:host-gateway" "--ulimit=nofile=65535:65535"];
      };
    };
  in {
    sops.secrets."searx-env" = {
      sopsFile = "${self}/secrets/searx-env";
      format = "dotenv";
    };

    services.searx = {
      enable = true;
      package = pkgs.searxng;
      redisCreateLocally = true;
      environmentFile = config.sops.secrets."searx-env".path;
      settings = {
        use_default_settings = true;
        server = {
          bind_address = "0.0.0.0";
          port = 8888;
          secret_key = "$SEARX_SECRET_KEY";
          limiter = false; # Firecrawl is the only client; the limiter would block it
        };
        search.formats = ["html" "json"];
      };
    };

    virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-containers.containers =
      lib.mapAttrs (_: c: c // {extraOptions = (c.extraOptions or []) ++ ["--network=${net}"];}) containers;

    systemd.services =
      {
        "podman-network-${net}" = {
          serviceConfig.Type = "oneshot";
          serviceConfig.RemainAfterExit = true;
          script = "${pkgs.podman}/bin/podman network exists ${net} || ${pkgs.podman}/bin/podman network create ${net}";
        };
      }
      // lib.mapAttrs' (name: _:
        lib.nameValuePair "podman-${name}" {
          requires = ["podman-network-${net}.service"];
          after = ["podman-network-${net}.service"];
        })
      containers;
  };
}
