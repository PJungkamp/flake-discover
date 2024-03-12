{pkgs, self, ...}: let
  recipe = {stdenv}: stdenv.mkDerivation {
    pname = "hello";
    version = "1.2.3";

    inherit (pkgs.hello) src;
  };
in pkgs.callPackage recipe {}
