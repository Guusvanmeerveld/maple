{
  description = "A Nix flake that makes it trivial to selfhost common Docker based services";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    docker-compose-nix = {
      url = "github:guusvanmeerveld/docker-compose-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
  }: {
    nixosModules = {
      default = import ./modules/nixos;
    };
  };
}
