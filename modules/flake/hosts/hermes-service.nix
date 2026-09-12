{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.hermesService = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [inputs.hermes-agent.nixosModules.default];

    sops.defaultSopsFile = "${self}/secrets/hermes-env";
    sops.defaultSopsFormat = "binary";
    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    sops.secrets."hermes-env" = {
      owner = "hermes";
      mode = "0400";
    };

    sops.secrets."email-env" = {
      sopsFile = "${self}/secrets/email-env";
      format = "dotenv";
      owner = "hermes";
      mode = "0400";
    };

    services.hermes-agent = {
      enable = true;
      extraPackages = [pkgs.git pkgs.gh];
      extraDependencyGroups = ["messaging" "supermemory"];
      addToSystemPackages = true;

      settings.model = {
        default = "free-first";
        provider = "omniroute";
        base_url = "https://omniroute.anshsonkusare.com/v1";
      };

      settings.providers = {
        omniroute = {
          type = "openai-compatible";
          base_url = "https://omniroute.anshsonkusare.com/v1";
        };
        openai.base_url = "https://omniroute.anshsonkusare.com/v1";
      };

      settings.fallback_providers = [
        {
          provider = "omniroute";
          model = "opencode/ling-3.0-flash-fin-free";
        }
        {
          provider = "omniroute";
          model = "opencode/mimo-v2.5-free";
        }
        {
          provider = "omniroute";
          model = "opencode/muse-spark-1.2";
        }
        {
          provider = "omniroute";
          model = "opencode/muse-spark-1.3";
        }
        {
          provider = "omniroute";
          model = "opencode/nemotron-3-ultra-free";
        }
        {
          provider = "omniroute";
          model = "opencode/nemotron-3.5-lightning-free";
        }
        {
          provider = "omniroute";
          model = "nvidia/nvidia/nemotron-3-ultra-550b-a55b";
        }
        {
          provider = "omniroute";
          model = "groq/openai/gpt-oss-120b";
        }
        {
          provider = "omniroute";
          model = "gemini/gemini-3.8-flash";
        }
        {
          provider = "omniroute";
          model = "auto/best-reasoning";
        }
      ];

      settings.memory = {
        memory_enabled = true;
        user_profile_enabled = true;
        memory_char_limit = 2200;
        user_char_limit = 1375;
        provider = "supermemory";
        write_approval = true;
      };

      settings.supermemory_config = {
        base_url = "http://localhost:6768";
        container_tag = "hermes";
        auto_recall = true;
        auto_capture = true;
      };

      backend.mode = "dashboard";
      backend.host = "0.0.0.0";

      environment = {
        API_SERVER_ENABLED = "true";
        API_SERVER_HOST = "0.0.0.0";
        API_SERVER_CORS_ORIGINS = "*";
        HERMES_DASHBOARD = "1";
        HERMES_DASHBOARD_BASIC_AUTH_USERNAME = "teak";
        HERMES_DISABLE_LAZY_INSTALLS = "1";
      };

      environmentFiles = [
        config.sops.secrets."hermes-env".path
        config.sops.secrets."email-env".path
      ];
    };
  };
}
