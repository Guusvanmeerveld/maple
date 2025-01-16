{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.maple.services.jellyfin;
  baseDir = config.maple.settings.storage.baseDir;
in {
  options = {
    maple.services.jellyfin = {
      enable = lib.mkEnableOption "Enable Jellyfin media streaming";

      version = lib.mkOption {
        type = lib.types.str;
        description = "The version of the Docker image to use. Latest can be found at: https://hub.docker.com/r/jellyfin/jellyfin";
        default = pkgs.jellyfin.version;
      };

      dirs = {
        config = lib.mkOption {
          type = lib.types.str;
          default = baseDir + "/jellyfin" + "/config";
        };

        cache = lib.mkOption {
          type = lib.types.str;
          default = baseDir + "/jellyfin" + "/cache";
        };

        media = lib.mkOption {
          type = lib.types.str;
          default = baseDir + "/jellyfin" + "/media";
        };
      };

      devices = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Devices to use for accelerated transcoding";
        default = ["/dev/dri/renderD128"];
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

      user = {
        uid = lib.mkOption {
          type = lib.types.int;
          default = 2000;
        };

        gid = lib.mkOption {
          type = lib.types.int;
          default = 2000;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    maple.docker.projects."jellyfin".services."jellyfin" = {
      image = "jellyfin/jellyfin:${cfg.version}";

      user = {
        create = true;

        uid = cfg.user.uid;
        gid = cfg.user.gid;

        runContainerAsUser = true;
      };

      volumes = [
        "${cfg.dirs.config}:/config"
        "${cfg.dirs.cache}:/cache"
        "${cfg.dirs.media}:/media"
      ];

      networks = ["jellyfin"];

      extraConfig = {
        devices = cfg.devices;
      };
    };

    maple.services.caddy.virtualHosts."${cfg.caddy.url}" = lib.mkIf cfg.caddy.enable {
      reverseProxy = "jellyfin:8096";
      networks = ["jellyfin"];
    };
  };
}
