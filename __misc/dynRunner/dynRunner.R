#
# 'dynRunner.R'
#
# note: defaults assume that getwd is in __misc/debug
#

xlsUnload <- function() dyn.unload( getLoadedDLLs()$xlsReadWrite[["path"]] )

xlsLoad <- function( dll, rsrc ){
  if (!is.null(getLoadedDLLs()$xlsReadWrite)) xlsUnload()
  info <- dyn.load( dll )
  invisible( apply( cbind( list.files( rsrc, full.names = TRUE ) ), 1, source ) )
}

dynTest <- function(filename, root = NA){
  root <- .dynSetup(root)
  runTest(file.path(root, "inst/RUnitTests", filename), outputDir = file.path(root, "__misc/debug/out"))
}

dynTests <- function(root = NA){
  root <- .dynSetup(root)
  runTests(file.path(root, "inst/RUnitTests"), outputDir = file.path(root, "__misc/debug/out"))
}

.dynSetup <- function(root) {
  if (is.na(root)) {
    stopifnot(basename(getwd()) == "debug")
    root <- file.path(getwd(), "../..")
  }
  xlsLoad(file.path(root, "src/pas/xlsReadWrite.dll"), file.path(root, "R"))
  source(file.path(root, "inst/RUnitTests/runner.R"))
  root
}
