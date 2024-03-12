{flake-discover-lib}: module @ {
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

  perSystemOptions = mkPerSystemOption (perSystem @ {
    config,
    pkgs,
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
      doImport = name: path: import path (perSystem // cfg.extraArgs);
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
    doImport = name: path: import path (module // cfg.extraArgs);
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
