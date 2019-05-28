lib:
rec {
  /* Add build flags to cabal
   */
  addBuildFlags = flags: drv: lib.overrideCabal drv (drv: {
    buildFlags = (drv.buildFlags or []) ++ flags;
  });

  /* Build derivation with -Wall flag
   */
  doWall     = addBuildFlags ["--ghc-option=-Wall"];

  /* Build derivation with -Wall and -Werror
   */
  doPedantic = addBuildFlags ["--ghc-option=-Wall" "--ghc-option=-Werror"];

  /* Build without optimizations
   */
  doNoOptimizations = addBuildFlags ["--ghc-option=-O0"];

  /* Add build derivation with profiling enabled
   */
  doProfile = drv: lib.enableExecutableProfiling (lib.enableLibraryProfiling drv);

  /* Add -dcore-lint GHC flag. It add internal checks to GHC optimizer
   * but slows down compilation by ~50%
   */
  doCoreLint = addBuildFlags ["--ghc-option=-dcore-lint"];
}
