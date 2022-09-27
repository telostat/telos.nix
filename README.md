# Custom Nix Packages and Utilities

![GitHub release (latest by date)](https://img.shields.io/github/v/release/telostat/telos.nix)
![GitHub contributors](https://img.shields.io/github/contributors/telostat/telos.nix)
![GitHub](https://img.shields.io/github/license/telostat/telos.nix)

This repository contains custom Nix packages and utilities used in our team.

Solutions to generic problems developed in this repository may gradually moved
into their own Git repositories.

## Usage

Direct URL import:

```nix
let
  telosnix = import (builtins.fetchTarball https://github.com/telostat/telos.nix/archive/<ref>.tar.gz) { };
in
{}
```

Using Niv:

```sh
niv add telostat/telos.nix -n telosnix -b <branch>
```

## Exports

Currently, following expressions are exported:

| Path                    | Description                                                              |
| ----------------------- | ------------------------------------------------------------------------ |
| `pkgs-sources.stable`   | Stable `nixpkgs` source (based on `release-22.05` `nixpkgs` branch)      |
| `pkgs-sources.unstable` | Unstable `nixpkgs` source (based on `nixpkgs-unstable` `nixpkgs` branch) |
| `tools.haskell`         | Various functions to make building Haskell development tools             |

## License

`telos.nix` is licensed under the MIT License.

Note: MIT license does not apply to the packages built, merely to the files in
this repository (the Nix expressions, build scripts, NixOS modules, etc.). It
also might not apply to patches included here, which may be derivative works of
the packages to which they apply. The aforementioned artifacts are all covered
by the licenses of the respective packages.
