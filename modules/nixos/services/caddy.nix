{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.maple.services.caddy;

  baseDir = config.maple.settings.storage.baseDir;

  networks = lib.flatten (lib.mapAttrsToList (host: options: options.networks) cfg.virtualHosts);

  caddyFile = pkgs.writeText "Caddyfile" ''
    {
      admin off
    }

    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (host: options: ''
        ${host} {
          reverse_proxy ${options.reverseProxy}
        }
      '')
      cfg.virtualHosts)}
  '';
in {
  options = {
    maple.services.caddy = {
      enable = lib.mkEnableOption "Enable Caddy HTTP proxy";

      version = lib.mkOption {
        type = lib.types.str;
        description = "The version of the Docker image to use. Latest can be found at: https://hub.docker.com/_/caddy";
        default = pkgs.caddy.version;
      };

      virtualHosts = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            reverseProxy = lib.mkOption {
              type = lib.types.str;

              description = "Specify a service that should be proxied using Caddy";
            };

            networks = lib.mkOption {
              type = lib.types.listOf lib.types.str;

              default = [];

              description = "Networks that Caddy needs to be in for this virtual host";
            };
          };
        });

        default = {};

        example = {
          "http://jellyfin.home" = {
            reverseProxy = "jellyfin:8096";

            networks = ["jellyfin"];
          };
        };

        description = "A list of hosts that need to be exposed via Caddy";
      };

      httpPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 80;
      };

      httpsPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 443;
      };

      openFirewall = lib.mkEnableOption "Open needed ports in firewall";

      dirs = {
        certs = lib.mkOption {
          type = lib.types.str;
          description = "The directory where certificates will be stored.";
          default = baseDir + "/caddy" + "/certs";
        };

        site = lib.mkOption {
          type = lib.types.str;
          default = baseDir + "/caddy" + "/site";
        };

        data = lib.mkOption {
          type = lib.types.str;
          default = baseDir + "/caddy" + "/data";
        };

        config = lib.mkOption {
          type = lib.types.str;
          default = baseDir + "/caddy" + "/config";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [cfg.httpPort cfg.httpsPort];

    maple.docker.projects."caddy".services."caddy" = {
      image = "caddy:${cfg.version}";

      ports = [
        "${toString cfg.httpPort}:80"
        "${toString cfg.httpsPort}:443"
      ];

      volumes = [
        "${caddyFile}:/etc/caddy/Caddyfile:ro"
        "${cfg.dirs.certs}:/data/caddy/certificates"
        "${cfg.dirs.site}:/srv"
        "${cfg.dirs.data}:/data"
        "${cfg.dirs.config}:/config"
      ];

      networks = networks;
    };
  };
}
