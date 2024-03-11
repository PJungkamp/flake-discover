{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    flake-discover = {
      url = "github:PJungkamp/flake-discover";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    }
  };

  outputs = inputs @ { self, ... }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [flake-discover.flakeModules.default];
      systems = ["x86_64-linux"];

      # the root directory for the auto-discover default directories
      discover.root = ./.;

      # auto-discover overlays (by default in "${config.discover.root}/overlays")
      discover.overlays.enable = true;

      perSystem.discover = {
        # auto-discover packages (by default in "${config.discover.root}/packages")
        packages.enable = true;
      };
    };
}
