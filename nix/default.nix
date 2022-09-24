let
  ## Import sources:
  sources = import ../nix/sources.nix;

  ## Pinned nixpkgs:
  pkgs = import sources.nixpkgs { };

  ## Pinned unstable nixpkgs:
  pkgs-unstable = import sources.nixpkgs-unstable { };
in
{
  sources = sources;
  pkgs = pkgs;
  pkgs-unstable = pkgs-unstable;
}
