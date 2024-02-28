# Edge

flake for the last version of edge on linux with tts/readaloud support.

# Usage

in `flake.nix` file

```nix
{
  inputs = { msedge.url = "github:sachnr/edge"; };
}
```

## As overlay

```nix
pkgs = import nixpkgs {
  inherit system;
  overlays = [
    inputs.msedge.overlays.${"x86_64-linux"}.default
  ];
};
```

## As package

```nix
  environment.systemPackages = [ inputs.msedge.packages.${"x86_64-linux"}.default ];
```
