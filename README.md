# Flake Discover

*auto-discover flake outputs from the file-hierarchy*

`flake-discover` is supposed to remove redundancy in the `flake.nix` files of simple flakes.
To provide this functionality it makes use of file system operations (`builtins.readDir` and `builtins.pathExists`) which are rather slow/inefficient in Nix.
You should probably **not** use `flake-discover` for larger package collections.

## Template

If you are defining a new flake, you might want to try the provided template to get started.

```shell
nix flake init -t github:PJungkamp/flake-discover
```

## Options

`flake-discover` provides two sets of options.
The toplevel `discover` options and the `perSystem.discover` options.

---

For one, you probably want to tell `flake-discover` where the root of your flake auto-discovery is.

```nix
discover.root = ./.;
```

The `discover.root` option defines the default locations of the built-in discoverable outputs.

---

You can then choose the the flake outputs you want to be auto discovered.

```nix
discover.overlays.enable = true;
perSystem.discover.packages.enable = true;
```

The directory for auto-discovery will default to `discover.root + "/${flakeOutput}"`.

---

You can customize the directory used for discovery with the `discover.<OUTPUT>.dir` options.

## Usage

The auto-discovered files are imported as functions which receive the `flake-parts` module arguments and all additional arguments from the `discover.extraArgs` or `perSystem.discover.extraArgs` options.

```nix
# both files and directories are supported
# - ${discover.root}/packages/example.nix
# - ${discover.root}/packages/example/default.nix
{
  pkgs,
  self,
  ...
}: let
  recipe = {
    rustPlatform,
  }: rustPlatform.buildRustPackage {
    pname = "example";
    version = "1.2.3";

    # use the flake.lock file for managing your source hashes
    src = self.inputs.example-src;

    # the cargoHash for dependencies fetched by cargo still needs to be set manually
    cargoHash = "sha256-tbrTbutUs5aPSV+yE0IBUZAAytgmZV7Eqxia7g+9zRs=";
  };
in pkgs.callPackage recipe {};
```
