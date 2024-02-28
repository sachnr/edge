{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ {self, ...}: let
    systems = ["x86_64-linux"];
  in
    inputs.flake-utils.lib.eachSystem systems (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      msedge = pkgs.callPackage ./edge.nix {};
    in {
      packages.default = msedge;
      overlays.default = final: prev: {microsoft-edge = msedge;};
    });
}
