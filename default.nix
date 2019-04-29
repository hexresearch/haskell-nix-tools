# common Nix utils for building haskell projects
pkgs:
let
  gitignore = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner  = "siers";
    repo   = "nix-gitignore";
    rev    = "ce0778ddd8b1f5f92d26480c21706b51b1af9166";
    sha256 = "1d7ab78i2k13lffskb23x8b5h24x7wkdmpvmria1v3wb9pcpkg2w";
  }) {};

in
{
  # Haskell specific tools
  hask          = import ./hask.nix pkgs.haskell.lib;

  # Ignore source from
  ignoreSources = ignore-list: source: gitignore.gitignoreSourceAux ignore-list source;

  # Apply function if flag is true. Otherwise do nothing
  #
  # doIf :: Bool -> (a -> a) -> (a -> a)
  doIf = flag: fun: if flag then fun else (x: x);
}
