{
  description = "auto-discover flake outputs from the file-hierarchy";

  inputs = {
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    nixpkgs-lib,
  }:
    flake-parts.lib.mkFlake {inherit inputs;} ({flake-parts-lib, ...}: let
      inherit (flake-parts-lib) importApply;

      lib = import ./lib.nix {
        inherit (nixpkgs-lib) lib;
      };

      flakeModules.default = importApply ./flake-module.nix {
        flake-discover-lib = lib;
      };
    in {
      systems = [];

      flake = {
        inherit flakeModules lib;

        templates.default = {
          path = ./template;
          description = "A simple flake showing the basic options of flake-discover";
        };
      };
    });
}
