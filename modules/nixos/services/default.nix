{...}: {
  imports = [
    ./caddy.nix
    ./watchtower.nix
    ./uptime-kuma.nix
    ./home-assistant.nix
    ./syncthing.nix
    ./jellyfin.nix
  ];
}
