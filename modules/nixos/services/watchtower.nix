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

      schedule = lib.mkOption {
        type = lib.types.str;
        default = "@daily";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.containers."watchtower".services."watchtower" = {
      image = "containrrr/watchtower";

      environment = {
        WATCHTOWER_CLEANUP = toString true;
        WATCHTOWER_SCHEDULE = cfg.schedule;
      };

      forwardDockerSocket = true;
    };
  };
}
