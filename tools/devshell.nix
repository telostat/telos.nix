{ pkgs, ... }:

let
  devshell-banner = pkgs.writeShellScriptBin "devshell-banner" ''
    ## Pretty-print the name of the devshell:
    "${pkgs.figlet}/bin/figlet" -c -t "''${DEVSHELL_NAME}" | "${pkgs.lolcat}/bin/lolcat" -S 20 -p 1 -F 0.02

    ## Show welcome notice:
    "${pkgs.rich-cli}/bin/rich" "''${DEVSHELL_WELCOME_FILE}"

    ## Last notice:
    echo "For further help, open the devshell book via \"devshell-book\""
  '';

  devshell-book = pkgs.writeShellScriptBin "devshell-book" ''
    xdg-open "''${DEVSHELL_DOCS_DIR}/book/html/index.html"
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
  ##   ## Create the devshell:
  ##   devshell = nix.telosnix.tools.devshell {
  ##     name = "devshell-example";
  ##     src = ./.;
  ##     welcome = ./README_welcome.md;
  ##     docs = [
  ##       { name = "readme"; title = "Introduction"; path = "./README.md"; }
  ##       { name = "welcome"; title = "Welcome to the Devshell"; path = "./README_welcome.md"; }
  ##       { name = "devshell"; title = "Devshell Help"; path = "./README_devshell.ronn"; }
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
  mkDevshell = { name, src, docs ? [], welcome }: with pkgs; stdenv.mkDerivation {
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

      ## Copy welcome message:
      cp "${welcome}" $out/share/doc/welcome.md

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
      cp ${devshell-banner}/bin/devshell-banner $out/bin/
      cp ${devshell-book}/bin/devshell-book $out/bin/

      ## Wrap devshell-banner program:
      wrapProgram $out/bin/devshell-banner \
        --set DEVSHELL_NAME "${name}" \
        --set DEVSHELL_WELCOME_FILE "$out/share/doc/welcome.md"

      ## Wrap devshell-list-docs program:
      wrapProgram $out/bin/devshell-book \
        --set DEVSHELL_NAME "${name}" \
        --set DEVSHELL_DOCS_DIR "$out/share/doc"
    '';
  };
in
mkDevshell
