{pkgs, inputs, self', ...}: let
  recipe = {stdenv}: stdenv.mkDerivation {
    pname = "hello";
    version = "1.2.3";

    # use the nixpkgs hello src attribute
    inherit (pkgs.hello) src;

    # refer to the self' argument of flake-parts
    # buildInputs = [self'.packages.some-package];

    # use your flake.lock to manage your recipes sources
    # src = inputs.hello-src;
  };
in
  pkgs.callPackage recipe {}
