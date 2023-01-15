{ pkgs, ... }:

let
  mkDevshell = import ./devsh.nix { pkgs = pkgs; };
in
mkDevshell
