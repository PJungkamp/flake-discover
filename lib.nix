{
  lib,
  flake-parts-lib,
  ...
}: let
  inherit (builtins) readDir split elemAt length pathExists;
  inherit (lib) types mkIf;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.attrsets) mapAttrs concatMapAttrs setAttrByPath;
  inherit (flake-parts-lib) mkPerSystemOption;
in rec {
  dirEntries = path: let
    toPath = n: v: path + "/${n}";
  in
    if pathExists path
    then mapAttrs toPath (readDir path)
    else {};

  forDirEntries = path: mapName: mapPath:
    concatMapAttrs (filename: filepath: let
      name = mapName filename;
      value = mapPath name filepath;
    in {${name} = value;}) (dirEntries path);

  splitStemExt = filename: let
    parts = split "\\.([^.]*)$" filename;
  in {
    stem = elemAt parts 0;
    ext =
      if length parts > 1
      then elemAt (elemAt parts 1) 0
      else null;
  };

  nixFileStem = name: let
    inherit (splitStemExt name) stem ext;
  in
    assert ext != null -> ext == "nix"; stem;

  mkDiscoverModule = {
    name,
    path ? [],
  }: {config, ...}: let
    cfg = config.discover;
    target = path ++ [name];
  in {
    options.discover.${name} = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "auto discovery of ${name}";

          dir = mkOption {
            type = types.path;
            default = cfg.root + "/${name}";
            defaultText = ''
              config.discover.root + "/${name}"
            '';
            description = ''
              directory in which ${name} are discovered.
            '';
          };
        };
      };
      default = {};
    };

    config = mkIf cfg.${name}.enable (setAttrByPath target (
      forDirEntries
      cfg.${name}.dir
      nixFileStem
      (name: path: import path cfg.args)
    ));
  };

  mkPerSystemDiscoverModule = args: {
    options.perSystem = mkPerSystemOption (mkDiscoverModule args);
  };
}
