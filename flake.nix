{
  description = "auto-discover flake outputs from the file-hierarchy";

  inputs = {
    # only use the `lib` subflake to speed up evaluation
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";

    # use flake-parts-lib for the flake options definition
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    nixpkgs-lib,
    nixpkgs,
  }:
    flake-parts.lib.mkFlake {inherit inputs;} ({flake-parts-lib, ...}: let
      inherit (flake-parts-lib) importApply;

      # the library for other flakes wanting to provide a discover option
      lib = import ./lib.nix {
        inherit (nixpkgs-lib) lib;
      };

      # importApply allows us to "dogfood" the module within this flake
      flakeModules.default = importApply ./flake-module.nix {
        flake-discover-lib = lib;
      };
    in {
      systems = ["x86_64-linux"];

      # "dogfood" the module
      imports = [flakeModules.default];

      # discover outputs relative to the flake root
      discover.root = ./.;

      perSystem = {
        pkgs,
        self,
        ...
      }: {
        # discover packages in ./packages
        discover.packages.enable = true;

        formatter = pkgs.alejandra;
      };

      flake = {
        inherit flakeModules lib;

        # provide a template for consuming flakes.
        templates.default = {
          path = ./template;
          description = "A simple flake showing the basic options of flake-discover";
        };
      };
    });
}
