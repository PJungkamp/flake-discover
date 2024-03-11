{flake-discover-lib}: {
  lib,
  self,
  flake-parts-lib,
  config,
  ...
}: let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (flake-discover-lib) mkDiscoverOption forDirEntries nixFileStem dirEntries;
  inherit (lib.attrsets) genAttrs mapAttrs filterAttrs getAttrs;
  inherit (lib) types mkIf;
  inherit (lib.options) mkOption;

  flakeAttrs = [
    "homeConfigurations"
    "homeModules"
    "nixosConfigurations"
    "nixosModules"
    "overlays"
  ];

  perSystemAttrs = [
    "checks"
    "devShells"
    "packages"
  ];

  root = config.discover.root;

  perSystemOptions = mkPerSystemOption ({
    config,
    pkgs,
    ...
  }: {
    options.discover =
      (genAttrs perSystemAttrs (mkDiscoverOption root))
      // {
        args = mkOption {
          type = with types; lazyAttrsOf raw;
          default = {};
        };
      };

    config = let
      cfg = config.discover;
      doCallPackage = name: path: pkgs.callPackage path cfg.args;
      mkPerSystemAttr = {
        enable,
        dir,
      }:
        mkIf enable (forDirEntries dir nixFileStem doCallPackage);
    in
      genAttrs perSystemAttrs (attr: mkPerSystemAttr cfg.${attr});
  });
in {
  options = {
    discover =
      (genAttrs flakeAttrs (mkDiscoverOption root))
      // {
        root = mkOption {
          type = types.path;
        };

        args = mkOption {
          type = with types; lazyAttrsOf raw;
          default = {};
        };
      };

    perSystem = perSystemOptions;
  };

  config.flake = let
    cfg = config.discover;
    doImport = name: path: import path cfg.args;
    mkFlakeAttr = {
      enable,
      dir,
    }:
      mkIf enable (forDirEntries dir nixFileStem doImport);
  in
    genAttrs flakeAttrs (attr: mkFlakeAttr cfg.${attr});
}
