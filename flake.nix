{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    nixpkgs,
  }:
    flake-parts.lib.mkFlake {inherit inputs;} ({flake-parts-lib, ...}: let
      inherit (flake-parts-lib) importApply;
      lib = import ./lib.nix {inherit (nixpkgs) lib;};
      flakeModules.default = importApply ./flake-module.nix {
        flake-discover-lib = lib;
      };
    in {
      imports = [flakeModules.default];
      systems = ["x86_64-linux"];

      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;
      };

      flake = {
        inherit flakeModules lib;

        templates.default = {
          path = ./templates/default;
          description = "";
        };
      };
    });
}
