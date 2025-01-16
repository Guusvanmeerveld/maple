{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.maple.services.uptime-kuma;
  baseDir = config.maple.settings.storage.baseDir;
in {
  options = {
    maple.services.uptime-kuma = {
      enable = lib.mkEnableOption "Enable Uptime Kuma uptime monitoring";

      version = lib.mkOption {
        type = lib.types.str;
        description = "The version of the Docker image to use. Latest can be found at: https://hub.docker.com/r/louislam/uptime-kuma";
        default = pkgs.uptime-kuma.version;
      };

      dirs = {
        data = lib.mkOption {
          type = lib.types.str;
          default = baseDir + "/uptime-kuma" + "/data";
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
    maple.docker.projects."uptime-kuma".services."uptime-kuma" = {
      image = "louislam/uptime-kuma:${cfg.version}";

      networks = ["uptime-kuma"];

      volumes = ["${cfg.dirs.data}:/app/data"];
    };

    maple.services.caddy.virtualHosts."${cfg.caddy.url}" = lib.mkIf cfg.caddy.enable {
      reverseProxy = "uptime-kuma:3001";
      networks = ["uptime-kuma"];
    };
  };
}
