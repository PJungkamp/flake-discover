toplevel @ {
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
  inherit (lib) types mkOption;

  root = config.discover.root;

  perSystemOptions = mkPerSystemOption (perSystem @ {
    config,
    inputs',
    pkgs,
    self',
    system,
    ...
  }: {
    options.discover = {
      root = mkOption {
        internal = true;
        type = types.path;
        default = toplevel.config.discover.root;
      };

      args = mkOption {
        internal = true;
        type = with types; lazyAttrsOf unspecified;
      };

      specialArgs = mkOption {
        type = with types; lazyAttrsOf unspecified;
        default = {};
      };
    };

    config.discover.args = let
      specialArgs = config.discover.specialArgs;
    in
      specialArgs
      // toplevel.config.discover.args
      // {
        inherit (perSystem) pkgs system self' inputs';
        inherit specialArgs;
      };
  });
in {
  options = {
    discover = {
      root = mkOption {
        type = types.path;
      };

      args = mkOption {
        internal = true;
        type = with types; lazyAttrsOf unspecified;
      };

      specialArgs = mkOption {
        type = with types; lazyAttrsOf unspecified;
        default = {};
      };
    };

    perSystem = perSystemOptions;
  };

  config.discover.args = let
    specialArgs = config.discover.specialArgs;
  in
    specialArgs
    // {
      inherit (toplevel) self inputs lib withSystem getSystem moduleWithSystem;
      inherit specialArgs;
    };
}
