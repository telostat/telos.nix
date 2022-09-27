let
  ## Nix packages override configuration for Haskell development
  ## tools.
  ##
  ## Usage:
  ##
  ##    devpkgs = import <nixpkgs-unstable> { inherit config-dev-hs; };
  ##    devpkgs = import telosnix.pkgs-sources.unstable { inherit config-dev-hs; };
  ##
  ## Note that this is NOT for the package being developed. It can
  ## have its own Nix packages source and configuration. This is
  ## rather for the Haskell tools such as language server, linters,
  ## formatters etc...
  ##
  ## The motivation is to:
  ##
  ## 1. Use latest Haskell development tools.
  ## 2. Benefit from Nix binary caches.
  ##
  ## For the latter, you should be using the same underlying package
  ## sources and GHC.
  config-dev-hs = {
    packageOverrides = pkgs: rec {
      haskellPackages = pkgs.haskellPackages.override {
        overrides = new: old: rec {
          apply-refact = old.apply-refact_0_10_0_0;
          Cabal = old.Cabal_3_6_3_0;
          fourmolu = old.fourmolu_0_8_2_0;
          ghc-lib-parser = old.ghc-lib-parser_9_2_4_20220729;
          hlint = old.hlint_3_5;
        };
      };
    };
  };

  ## Imports and returns a given Nix packages source with our custom
  ## Nix packages override configuration for Haskell development
  ## tools.
  get-haskell-development-packages = source:
    import source { inherit config-dev-hs; };

  ## Imports and returns a compiler specific Haskell packages set with
  ## our custom Nix packages override configuration for Haskell
  ## development tools.
  get-haskell-development-compiler = source: compiler:
    (get-haskell-development-packages source).haskell.packages.${compiler};

  ## Returns common Haskell development tools for the given Nix
  ## packages source with our custom Nix packages override
  ## configuration for Haskell development tools.
  get-haskell-development-tools = source: compiler:
    let
      haskell = get-haskell-development-compiler source compiler;
    in
    [
      haskell.apply-refact
      haskell.fourmolu
      haskell.haskell-language-server
      haskell.hlint
    ];
in
{
  config-dev-hs = config-dev-hs;
  get-haskell-development-packages = get-haskell-development-packages;
  get-haskell-development-compiler = get-haskell-development-compiler;
  get-haskell-development-tools = get-haskell-development-tools;
}
