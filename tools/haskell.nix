## This module provides Haskell development helpers and tools which
## are somewhat opinionated.
##
## In particular, the motivation is (1) to access some Haskell
## development tools (such as apply-refact, fourmolu,
## haskell-language-server, hlint etc...) in all projects that make
## use of telos.nix, and (2) while doing so, to benefit from (at least
## local) binary caches to avoid long compilation times for these
## tools.
let
  ## Provides a helper function that overrides Haskell packages for
  ## our custom Haskell development tools.
  ##
  ## Usage:
  ##
  ## pkgs.haskellPackages.override {
  ##   overrides = overrideHaskellForDevTools;
  ## };
  overrideHaskellForDevTools =
    new: old: {
      ## Placeholder for overriding Haskell packages in case required.
    };

  ## Returns the Haskell set for development purposes.
  ##
  ## In particular, it overrides packages for our custom Haskell
  ## development tools and optional overrides provided.
  ##
  ## Usage:
  ##
  ##     override-haskell-for-package = new: old: rec {
  ##       relude = my-own-relude;
  ##     };
  ##
  ##     haskell = telosnix.tools.haskell.getHaskell
  ##       {
  ##         pkgs = my-pkgs;
  ##         compiler = my-compiler;
  ##         overrides = override-haskell-for-package;
  ##       };
  ##
  ##     ghc = haskell.ghcWithPackages (_: my-haskell-package-deps);
  ##
  ##     haskell-dev-tools-for-my-shell = with haskell;
  ##       [
  ##         ## Our GHC with all packages required to build and test our package:
  ##         ghc
  ##
  ##         ## Various haskell tools:
  ##         apply-refact
  ##         cabal-install
  ##         cabal2nix
  ##         fourmolu
  ##         haskell-language-server
  ##         hlint
  ##         hpack
  ##       ];
  getHaskell =
    { pkgs
    , compiler
    , overrides ? new: old: { }
    }:
    let
      overrider = new: old:
        let
          withTools = overrideHaskellForDevTools new old;
          requested = overrides new old;
        in
        withTools // requested
      ;
    in
    pkgs.haskell.packages.${compiler}.override {
      overrides = overrider;
    };
in
{
  overrideHaskellForDevTools = overrideHaskellForDevTools;
  getHaskell = getHaskell;
}
