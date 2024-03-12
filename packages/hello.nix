{pkgs, ...}: let
  recipe = {hello}: hello;
in
  pkgs.callPackage recipe {}
