{ compiler ? "ghc902"
, ...
}:

let
  ## Pinned nixpkgs:
  pkgs = (import ../nix).pkgs-unstable;

  ## Get the haskell set with overrides:
  haskell = pkgs.haskell.packages.${compiler}.override {
    overrides = self: super: with pkgs.haskell.lib; {
      fourmolu = super.fourmolu_0_8_2_0;
      Cabal = super.Cabal_3_6_3_0;
      ghc-lib-parser = super.ghc-lib-parser_9_2_4_20220729;
    };
  };
in
{
  haskell = haskell;

  packages = {
    fourmolu = haskell.fourmolu;
  };
}
