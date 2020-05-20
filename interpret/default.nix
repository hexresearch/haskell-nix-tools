# Declaratively (more or less) configure package set for the haskell
# development. This functions generates overrides for several packages
# at once and meanty to be used in following manner:
#
# > haskTools = import (pkgs.fetchFromGitHub {
# >   owner  = "hexresearch";
# >   repo   = "haskell-nix-tools";
# >   rev    = "...";
# >   sha256 = "...";
# > }) pkgs;
# >
# > config = {
# >   ...
# >   packageOverrides = super: {
# >     haskell = haskTools.interpret pkgs super {
# >       flags         = {...};
# >       release       = customPackages;
# >     };
# >     ...
# >   };
# > };
# >
#
# Or alternatively for overlays
#
# > overlay = self: super: {
# >   haskell = haskTools.interpret self super {
# >     overrides = {...};
# >     release   = xenoPackages;
# >   };
# > };

# Fields of parameter record have folloing meaning:
#
# * flags contains adjustments to flags of package such as
#   dontCheck/dontHaddock/haddock. They could be specified both for all
#   versions of GHC and on per-GHC basis.
#
# * release nix expressions for any other packages
#
#
# It also add following pseudo packages into haskell namespace:
#
#  * local-overrides  - comparison of version of overrides and packages in nix
#  * release-packages - dictionary of packages from release field
pkgs:
super:
spec:
let
  lib = pkgs.haskell.lib;
in let
  # Create dictionary of functions which will modify flags for haskell
  # packages in set
  flagOverrides = import ./flags.nix pkgs spec.overrides;
in let
  # Create overrides for different GHC version
  makeOverride = super: ghc: addFlags:
    super."${ghc}".override {
      overrides = hsSelf: hsSuper:
        let
          readExtra   = dir: lib.packagesFromDirectory { directory = dir; } hsSelf hsSuper;
          deriv       = spec.overrides.derivations;
          extraCommon = if builtins.isList deriv.haskell
            then builtins.foldl' (r: path: r // readExtra path) {} deriv.haskell
            else readExtra deriv.haskell;
          extraPerGhc = if builtins.hasAttr "${ghc}" deriv
            then readExtra deriv."${ghc}"
            else {};
          release     = spec.release hsSelf;
          # Compute synopsis for package overrides
          compare = k: v:
            let
              nix-version = hsSuper."${k}".version or null;
            in {
              inherit (v) version name;
              inherit nix-version;
              newer = if nix-version != null then builtins.compareVersions v.version nix-version else null;
            };
          overridedVer = builtins.mapAttrs compare (extraCommon // extraPerGhc);
        in
          addFlags (hsSuper // extraCommon // extraPerGhc // release) // {
            local-overrides  = overridedVer;
            release-packages = builtins.mapAttrs (k: _: hsSelf."${k}") release;
          }
      ;
    };
  overridesPerGhc = super:
    (builtins.mapAttrs (makeOverride super) flagOverrides)
  ;
in
# Replace overridden package sets
super.haskell // {
  packages = super.haskell.packages // overridesPerGhc super.haskell.packages;
}
