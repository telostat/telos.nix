{ pkgs, ... }:

let
  devshell-banner = pkgs.writeShellScriptBin "devshell-banner" ''
    ## Pretty-print the name of the devshell:
    "${pkgs.figlet}/bin/figlet" -c -t "''${DEVSHELL_NAME}" | "${pkgs.lolcat}/bin/lolcat" -S 20 -p 1 -F 0.02

    ## Show welcome notice:
    "${pkgs.rich-cli}/bin/rich" "''${DEVSHELL_WELCOME_FILE}"

    ## Last notice:
    echo "For further help: man devshell"
  '';

  ## Example usage:
  ##
  ## ```
  ## { compiler ? "ghc92" }:
  ##
  ## let
  ##   ## Import this codebase's Nix helper set:
  ##   nix = import ./nix { compiler = compiler; };
  ##
  ##   ## Get packages:
  ##   pkgs = nix.pkgs;
  ##
  ##   ## Get the devshell tool:
  ##   devshell = nix.telosnix.tools.devshell {
  ##     name = "devshell-example";
  ##     welcome = ./README_welcome.md;
  ##     help = ./README_devshell.ronn;
  ##     src = ./.;
  ##   };
  ## in
  ## pkgs.mkShell {
  ##   buildInputs = [
  ##     devshell
  ##   ] ++ nix.haskell-dev-tools;
  ##
  ##   shellHook = ''
  ##     devshell-banner
  ##
  ##     ## Make sure that doctest finds correct GHC executable and libraries:
  ##     export NIX_GHC=${nix.ghc}/bin/ghc
  ##     export NIX_GHC_LIBDIR=${nix.ghc}/lib/${nix.ghc.meta.name}
  ##   '';
  ## }
  ## ```
  mkDevshell = { name, welcome, help, src }: with pkgs; stdenv.mkDerivation {
    name = name;
    src = src;
    DEVSHELL_NAME = name;

    nativeBuildInputs = [
      makeWrapper
      installShellFiles
    ];

    installPhase = ''
      ## Create output directories:
      mkdir -p $out/bin
      mkdir -p $out/etc
      mkdir -p $out/share/doc

      ## Copy welcome message:
      cp "${welcome}" $out/share/doc/devshell-welcome.md

      ## Copy ronn file for help:
      cp "${help}" $out/share/doc/devshell.ronn

      ## Create a temporary directory for ronn output:
      mkdir ''${TMP}/man/

      ## Compile ronn file:
      ${pkgs.ronn}/bin/ronn --output-dir ''${TMP}/man/ $out/share/doc/devshell.ronn

      ## Install manpages:
      installManPage ''${TMP}/man/*

      ## Copy our program to the output destination:
      cp ${devshell-banner}/bin/devshell-banner $out/bin/

      ## Wrap program to add PATHs to dependencies:
      wrapProgram $out/bin/devshell-banner \
        --set DEVSHELL_NAME "${name}" \
        --set DEVSHELL_WELCOME_FILE "$out/share/doc/devshell-welcome.md"
    '';
  };
in
mkDevshell
