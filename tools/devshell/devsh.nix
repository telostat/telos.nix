{ pkgs }:

let
  ## Create devsh script:
  scriptDevsh = pkgs.writeScriptBin "devsh" (builtins.readFile ./devsh.py);

  ## Import devshell guide tools:
  devshGuide = import ./devsh-guide.nix { pkgs = pkgs; };

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
  ##   ## Create the devshell:
  ##   devshell = nix.telosnix.tools.devshell {
  ##     name = "devshell-example";
  ##     src = ./.;
  ##     quickstart = ./README_quickstart.md;
  ##     guide = [
  ##       { name = "readme"; title = "Introduction"; path = "./README.md"; }
  ##       { name = "quickstart"; title = "Quickstart"; path = "./README_quickstart.md"; }
  ##       { name = "another-guide"; title = "Another Guide"; path = "./README_guide.ronn"; }
  ##     ];
  ##     ## Or you can provide the path of a mdBook:
  ##     ## guide = ./nix/docs/development;
  ##     extensions = {
  ##       my-command = {
  ##         help = "Help for my command";
  ##         exec = "${my-command}/bin/my-command";
  ##       };
  ##     };
  ##   };
  ## in
  ## pkgs.mkShell {
  ##   buildInputs = [
  ##     devshell
  ##   ] ++ nix.haskell-dev-tools;
  ##
  ##   shellHook = ''
  ##     devsh welcome
  ##     echo
  ##     devsh exec
  ##
  ##     ## Make sure that doctest finds correct GHC executable and libraries:
  ##     export NIX_GHC=${nix.ghc}/bin/ghc
  ##     export NIX_GHC_LIBDIR=${nix.ghc}/lib/${nix.ghc.meta.name}
  ##   '';
  ## }
  ## ```
  mkDevshell = { name, src, quickstart, guide ? [ ], extensions ? { } }:
    with pkgs;
    let
      extensionDrvs = lib.attrsets.mapAttrs (name: value: writeShellScriptBin "devsh-extension-${name}" "${value.exec} \"\${@}\"") extensions;
      extensionHelp = lib.strings.concatStrings (lib.attrsets.attrValues (lib.attrsets.mapAttrs (name: value: "${name}: ${value.help}\n") extensions));
      extensionHelpFile = writeTextFile { name = "extensions.dat"; text = extensionHelp; };
      binPathDevsh = lib.makeBinPath ([ figlet lolcat rich-cli ] ++ (lib.attrsets.attrValues extensionDrvs));
      guideDevsh = devshGuide.mkGuide { source = guide; };
    in
    stdenv.mkDerivation {
      name = name;
      src = src;

      nativeBuildInputs = [ makeWrapper ];

      installPhase = ''
        ## Create output directories:
        mkdir -p $out/bin
        mkdir -p $out/etc
        mkdir -p $out/share/doc/

        ## Copy quickstart guide:
        cp "${quickstart}" $out/share/doc/quickstart.md

        ## Copy devshell extensions help:
        cp "${extensionHelpFile}" $out/share/doc/extensions.dat

        ## Copy the guide:
        cp -R "${guideDevsh}/share/doc/guide" $out/share/doc/

        ## Copy scripts to the output destination:
        cp ${scriptDevsh}/bin/devsh $out/bin/

        ## Wrap devsh program:
        wrapProgram $out/bin/devsh \
          --prefix PATH : ${binPathDevsh} \
          --set DEVSHELL_NAME "${name}" \
          --set DEVSHELL_DOCS_DIR "$out/share/doc" \
          --set DEVSHELL_QUICKSTART "$out/share/doc/quickstart.md" \
          --set DEVSHELL_EXTENSIONS "$out/share/doc/extensions.dat"
      '';
    };
in
mkDevshell
