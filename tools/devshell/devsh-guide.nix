{ pkgs, ... }:

with pkgs;

let
  mkGuide = { source }:
    let
      prepare = if builtins.isPath source then mkGuideFromBook else mkGuideFromDocs;
    in
    prepare source;

  mkGuideFromBook = book: stdenv.mkDerivation {
    name = "devshell-guide";
    unpackPhase = "true";

    installPhase = ''
      ## Create output directories:
      mkdir -p $out/share/doc/guide/

      ## Copy the book to destination:
      cp -LR "${book}/." $out/share/doc/guide/

      ## Create the HTML output directory:
      mkdir -p $out/share/doc/guide/html

      ## Build the book:
      "${mdbook}/bin/mdbook" build --dest-dir $out/share/doc/guide/html $out/share/doc/guide
    '';
  };

  mkGuideFromDocs = docs: stdenv.mkDerivation {
    name = "devshell-guide";
    unpackPhase = "true";

    installPhase = ''
      ## Create output directories:
      mkdir -p $out/share/doc/guide/src
      mkdir -p $out/share/doc/guide/html

      ## Copy the devshell guide sections:
      ${toString (map ({name, title, path}: "cp \"${path}\" $out/share/doc/guide/src/${name}.md\n") docs)}

      ## Write devshell guide index:
      cat <<EOF > $out/share/doc/guide/src/SUMMARY.md
      ${toString (map ({name, title, path}: "- [${title}](${name}.md)\n") docs)}
      EOF

      ## Write devshell guide configuration:
      cat <<EOF > $out/share/doc/guide/book.toml
      [book]
      title = "Development Shell Guide"
      description = "This is the Development Shell Guide."

      [output.html]
      default-theme = "light"
      preferred-dark-theme = "ayu"
      curly-quotes = true
      mathjax-support = true
      copy-fonts = true
      EOF

      ## Build the book:
      "${mdbook}/bin/mdbook" build --dest-dir $out/share/doc/guide/html $out/share/doc/guide
    '';
  };
in
{
  mkGuide = mkGuide;
}
