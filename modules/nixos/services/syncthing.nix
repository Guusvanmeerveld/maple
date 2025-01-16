{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.maple.services.syncthing;
  baseDir = config.maple.settings.storage.baseDir;
in {
  options = {
    maple.services.syncthing = {
      enable = lib.mkEnableOption "Enable Syncthing peer-to-peer file synchronization";

      version = {
        type = lib.types.str;
        description = "The version of the Docker image to use. Latest can be found at: https://github.com/syncthing/core/pkgs/container/syncthing";
        default = pkgs.syncthing.version;
      };

      dirs = {
        config = lib.mkOption {
          type = lib.types.str;
          default = baseDir + "/syncthing" + "/config";
        };

        sync = lib.mkOption {
          type = lib.types.str;
          default = baseDir + "/syncthing" + "/sync";
        };
      };

      fileTransferPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 22000;
      };

      discoveryPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 21027;
      };

      openFirewall = lib.mkEnableOption "Open needed ports in firewall";

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
    maple.docker.projects."syncthing".services."syncthing" = {
      image = "syncthing/syncthing:${cfg.version}";

      environment = {
        STHOMEDIR = "/config";
      };

      volumes = [
        "${cfg.dirs.config}:/config"
        "${cfg.dirs.sync}:/var/syncthing"
      ];

      ports = [
        "${cfg.fileTransferPort}:22000/tcp" # TCP file transfers
        "${cfg.fileTransferPort}:22000/udp" # QUIC file transfers
        "${cfg.discoveryPort}:21027/udp" # Receive local discovery broadcasts
      ];

      networks = ["syncthing"];
    };

    maple.services.caddy.virtualHosts."${cfg.caddy.url}" = lib.mkIf cfg.caddy.enable {
      reverseProxy = "syncthing:8384";
      networks = ["syncthing"];
    };
  };
}
