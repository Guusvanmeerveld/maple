{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.maple.services.home-assistant;
  baseDir = config.maple.settings.storage.baseDir;
in {
  options = {
    maple.services.home-assistant = {
      enable = lib.mkEnableOption "Enable Home Assistant smart home management";

      version = lib.mkOption {
        type = lib.types.str;
        description = "The version of the Docker image to use. Latest can be found at: https://github.com/home-assistant/core/pkgs/container/home-assistant";
        default = pkgs.home-assistant.version;
      };

      dirs = {
        config = lib.mkOption {
          type = lib.types.str;
          default = baseDir + "/home-assistant" + "/config";
        };
      };

      caddy = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = config.maple.services.caddy.enable;
        };

        url = lib.mkOption {
          type = lib.types.str;
          description = "External url to access this instance";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    maple.docker.projects."home-assistant".services."home-assistant" = {
      image = "ghcr.io/home-assistant/home-assistant:${cfg.version}";

      volumes = ["${cfg.dirs.config}:/config"];

      networks = ["home-assistant"];
    };

    maple.services.caddy.virtualHosts."${cfg.caddy.url}" = lib.mkIf cfg.caddy.enable {
      reverseProxy = "home-assistant:8123";
      networks = ["home-assistant"];
    };
  };
}
