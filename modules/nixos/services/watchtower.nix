{
  lib,
  config,
  ...
}: let
  cfg = config.maple.services.watchtower;
in {
  options = {
    maple.services.watchtower = {
      enable = lib.mkEnableOption "Enable Watchtower Docker image clean up";

      version = {
        type = lib.types.str;
        description = "The version of the Docker image to use. Latest can be found at: https://hub.docker.com/r/containrrr/watchtower";
        default = "latest";
      };

      schedule = lib.mkOption {
        type = lib.types.str;
        default = "@daily";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    maple.docker.projects."watchtower".services."watchtower" = {
      image = "containrrr/watchtower:${cfg.version}";

      environment = {
        WATCHTOWER_CLEANUP = toString true;
        WATCHTOWER_SCHEDULE = cfg.schedule;
      };

      forwardDockerSocket = true;
    };
  };
}
