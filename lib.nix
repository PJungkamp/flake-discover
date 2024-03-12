{lib}: let
  inherit (builtins) readDir split elemAt length pathExists;
  inherit (lib) types;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.attrsets) mapAttrs concatMapAttrs;
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

  mkDiscoverOption = root: attr: {
    enable = mkEnableOption "auto discovery of ${attr}";

    dir = mkOption {
      type = types.path;
      default = root + "/${attr}";
      description = ''
        directory in which ${attr} are discovered.
      '';
    };
  };
}
