{ ... }:

let
  sources = import ./nix/sources.nix;
in
{
  ## Pinned Nix package sources.
  ##
  ## These can be used in various projects to benefit from Nix caching.
  pkgs-sources = {
    stable = sources.nixpkgs;
    unstable = sources.nixpkgs-unstable;
  };

  ## Categorized tools.
  tools = {
    devshell = import ./tools/devshell.nix { pkgs = import sources.nixpkgs { }; };
    haskell = import ./tools/haskell.nix;
  };
}
