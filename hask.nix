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

  /* Install tests executables alongside with everything else. It's
    * needed when debugging intermittent test failures
    */
  doInstallTests = drv: lib.overrideCabal drv (drv: { postInstall = ''
    mkdir $out/tests
    for tst in $(grep -i test-suite *.cabal | sed -e 's/ $//; s/.* //'); do
        if [ $(find -name $tst -type f | wc -l) == 1 ]; then
            cp -v $(find -name $tst -type f ) $out/tests
        fi
    done
    '';});
}
