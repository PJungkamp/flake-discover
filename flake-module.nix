{flake-discover-lib}: flake @ {
  config,
  flake-parts-lib,
  inputs,
  lib,
  self,
  withSystem,
  getSystem,
  moduleWithSystem,
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

  toplevelSpecialArgs = {
    inherit (flake) self inputs lib withSystem getSystem moduleWithSystem;
  };

  root = config.discover.root;

  perSystemOptions = mkPerSystemOption (perSystem @ {
    config,
    inputs',
    pkgs,
    self',
    system,
    ...
  }: {
    options.discover =
      (genAttrs perSystemAttrs (mkDiscoverOption root))
      // {
        extraArgs = mkOption {
          type = with types; lazyAttrsOf raw;
          default = {};
        };
      };

    config = let
      cfg = config.discover;

      perSystemSpecialArgs = {
        inherit (perSystem) pkgs system self' inputs';
      };

      doImport = name: path: import path ({
        inherit (flake) self inputs lib withSystem getSystem moduleWithSystem;
        inherit (perSystem) pkgs system self' inputs';
      } // cfg.extraArgs);

      mkPerSystemAttr = {
        enable,
        dir,
      }:
        if enable
        then forDirEntries dir nixFileStem doImport
        else {};
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

        extraArgs = mkOption {
          type = with types; lazyAttrsOf raw;
          default = {};
        };
      };

    perSystem = perSystemOptions;
  };

  config.flake = let
    cfg = config.discover;

    doImport = name: path: import path ({
      inherit (flake) self inputs lib withSystem getSystem moduleWithSystem;
    } // cfg.extraArgs);

    mkFlakeAttr = {
      enable,
      dir,
    }:
      if enable
      then forDirEntries dir nixFileStem doImport
      else {};
  in
    genAttrs flakeAttrs (attr: mkFlakeAttr cfg.${attr});
}
