{ overrideCabal }:
rec {
  # Add build flags to cabal
  addBuildFlags = flags: drv: overrideCabal drv (drv: {
    buildFlags = (drv.buildFlags or []) ++ flags;
  });

  # Build derivation with -Wall flag
  doWall     = addBuildFlags ["--ghc-option=-Wall"];

  # Build derivation with -Wall and -Werror
  doPedantic = addBuildFlags ["--ghc-option=-Wall" "--ghc-option=-Werror"];

  # Build without optimizations
  doNoOptimizations = addBuildFlags ["--ghc-option=-O0"];
}
