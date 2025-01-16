{lib, ...}: {
  options = {
    maple.settings = {
      storage = {
        baseDir = lib.mkOption {
          type = lib.types.str;
          description = "The base directory used to store service data";
          default = "/var/lib/maple";
        };
      };
    };
  };
}
