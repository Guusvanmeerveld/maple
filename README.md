# Maple

Maple is an opinionated Nix flake that provides a selection of self hosted services so that they can easily be installed to your favorite Nix based machines.
This is perfect if you want to quickly setup some Docker services, but cannot be bothered to manually create the docker-compose and tweak it to your custom use case.
It makes use of another flake of mine, [docker-compose-nix](https://github.com/guusvanmeerveld/docker-compose-nix) to make this happen.

## Example

```nix
{
    config = {
        maple.services.jellyfin = {
            enable = true;

            url = "http://jellyfin.home";
        };
    };
}
```

## Installation

### With flakes

Add the following into the desired flake.nix file.

```
{
    inputs.maple.url = "github:guusvanmeerveld/maple";
}
```
