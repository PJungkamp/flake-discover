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
  }:
    flake-parts.lib.mkFlake {inherit inputs;} ({flake-parts-lib, ...}: let

      # the library for other flakes wanting to provide a discover option
      lib = import ./lib.nix {
        inherit (nixpkgs-lib) lib;
        inherit flake-parts-lib;
      };

      modules = {
        base = import ./flake-module.nix;

        overlays = lib.mkDiscoverModule {
          name = "overlays";
          path = ["flake"];
        };

        nixosModules = lib.mkDiscoverModule {
          name = "nixosModules";
          path = ["flake"];
        };

        nixosConfigurations = lib.mkDiscoverModule {
          name = "nixosConfigurations";
          path = ["flake"];
        };

        homeModules = lib.mkDiscoverModule {
          name = "homeModules";
          path = ["flake"];
        };

        homeConfigurations = lib.mkDiscoverModule {
          name = "homeConfigurations";
          path = ["flake"];
        };

        templates = lib.mkDiscoverModule {
          name = "templates";
          path = ["flake"];
        };

        recipes = lib.mkDiscoverModule {
          name = "recipes";
          path = ["flake"];
        };

        packages = lib.mkPerSystemDiscoverModule {
          name = "packages";
        };

        devShells = lib.mkPerSystemDiscoverModule {
          name = "devShells";
        };

        checks = lib.mkPerSystemDiscoverModule {
          name = "checks";
        };

        apps = lib.mkPerSystemDiscoverModule {
          name = "apps";
        };
      };
    in {
      systems = [];

      flake = {
        inherit lib;

        flakeModules = modules // {
          default.imports = builtins.attrValues modules;
        };

        templates.default = {
          path = ./template;
          description = "A simple flake showing the basic options of flake-discover";
        };
      };
    });
}
