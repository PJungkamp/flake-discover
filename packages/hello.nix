{pkgs, ...}:
let
  recipe = {hello, stdenv}: stdenv.mkDerivation {
    pname = "my-hello";
    inherit (hello) version src;
  };
in pkgs.callPackage recipe {}
