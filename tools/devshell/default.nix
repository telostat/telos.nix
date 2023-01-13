{ pkgs, ... }:

let
  devsh = pkgs.writeScriptBin "devsh" (builtins.readFile ./devsh.py);

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
  ##       { name = "guide"; title = "Guide"; path = "./README_guide.ronn"; }
  ##     ];
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
  mkDevshell = { name, src, docs ? [], quickstart }: with pkgs; stdenv.mkDerivation {
    name = name;
    src = src;
    DEVSHELL_NAME = name;

    nativeBuildInputs = [
      makeWrapper
    ];

    installPhase = ''
      ## Create output directories:
      mkdir -p $out/bin
      mkdir -p $out/etc
      mkdir -p $out/share/doc/book/src
      mkdir -p $out/share/doc/book/html

      ## Copy quickstart guide:
      cp "${quickstart}" $out/share/doc/quickstart.md

      ## Copy the devshell book sections:
      ${toString (map ({name, title, path}: "cp \"${path}\" $out/share/doc/book/src/${name}.md\n") docs)}

      ## Write devshell book index:
      cat <<EOF > $out/share/doc/book/src/SUMMARY.md
      ${toString (map ({name, title, path}: "- [${title}](${name}.md)\n") docs)}
      EOF

      ## Write devshell book configuration:
      cat <<EOF > $out/share/doc/book/book.toml
      [book]
      title = "${name}"
      description = "This is the Development Shell book for ${name}."

      [output.html]
      default-theme = "light"
      preferred-dark-theme = "ayu"
      curly-quotes = true
      mathjax-support = true
      copy-fonts = true
      EOF

      ## Build devshell book:
      "${mdbook}/bin/mdbook" build --dest-dir $out/share/doc/book/html $out/share/doc/book

      ## Copy scripts to the output destination:
      cp ${devsh}/bin/devsh $out/bin/

      ## Wrap devsh program:
      wrapProgram $out/bin/devsh \
        --prefix PATH : ${lib.makeBinPath [ figlet lolcat rich-cli ]} \
        --set DEVSHELL_NAME "${name}" \
        --set DEVSHELL_DOCS_DIR "$out/share/doc" \
        --set DEVSHELL_QUICKSTART "$out/share/doc/quickstart.md"
    '';
  };
in
mkDevshell
