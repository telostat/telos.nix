{ pkgs }:

let
  ## Create devsh script:
  scriptDevsh = pkgs.writeScriptBin "devsh" (builtins.readFile ./devsh.py);

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
  ##     docs = [
  ##       { name = "readme"; title = "Introduction"; path = "./README.md"; }
  ##       { name = "quickstart"; title = "Quickstart"; path = "./README_quickstart.md"; }
  ##       { name = "another-guide"; title = "Another Guide"; path = "./README_guide.ronn"; }
  ##     ];
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
  ##     devshell-banner
  ##
  ##     ## Make sure that doctest finds correct GHC executable and libraries:
  ##     export NIX_GHC=${nix.ghc}/bin/ghc
  ##     export NIX_GHC_LIBDIR=${nix.ghc}/lib/${nix.ghc.meta.name}
  ##   '';
  ## }
  ## ```
  mkDevshell = { name, src, quickstart, docs ? [ ], extensions ? { } }:
    with pkgs;
    let
      extensionDrvs = lib.attrsets.mapAttrs (name: value: writeShellScriptBin "devsh-extension-${name}" "${value.exec} \"\${@}\"") extensions;
      extensionHelp = lib.strings.concatStrings (lib.attrsets.attrValues (lib.attrsets.mapAttrs (name: value: "${name}: ${value.help}\n") extensions));
      extensionHelpFile = writeTextFile { name = "extensions.dat"; text = extensionHelp; };
      binPathDevsh = lib.makeBinPath ([ figlet lolcat rich-cli ] ++ (lib.attrsets.attrValues extensionDrvs));
    in
    stdenv.mkDerivation {
      name = name;
      src = src;

      nativeBuildInputs = [ makeWrapper ];

      installPhase = ''
        ## Create output directories:
        mkdir -p $out/bin
        mkdir -p $out/etc
        mkdir -p $out/share/doc/guide/src
        mkdir -p $out/share/doc/guide/html

        ## Copy quickstart guide:
        cp "${quickstart}" $out/share/doc/quickstart.md

        ## Copy devshell extensions help:
        cp "${extensionHelpFile}" $out/share/doc/extensions.dat

        ## Copy the devshell guide sections:
        ${toString (map ({name, title, path}: "cp \"${path}\" $out/share/doc/guide/src/${name}.md\n") docs)}

        ## Write devshell guide index:
        cat <<EOF > $out/share/doc/guide/src/SUMMARY.md
        ${toString (map ({name, title, path}: "- [${title}](${name}.md)\n") docs)}
        EOF

        ## Write devshell guide configuration:
        cat <<EOF > $out/share/doc/guide/book.toml
        [book]
        title = "${name}"
        description = "This is the Development Shell Guide for ${name}."

        [output.html]
        default-theme = "light"
        preferred-dark-theme = "ayu"
        curly-quotes = true
        mathjax-support = true
        copy-fonts = true
        EOF

        ## Build devshell guide:
        "${mdbook}/bin/mdbook" build --dest-dir $out/share/doc/guide/html $out/share/doc/guide

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
