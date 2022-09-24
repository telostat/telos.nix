let
  nix = (import ./nix);
in
{
  pkgs = {
    stable = nix.pkgs;
    unstable = nix.pkgs-unstable;
  };

  tools = {
    haskell = import ./tools/haskell.nix { };
  };
}
