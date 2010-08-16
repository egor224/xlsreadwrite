#
# 'dynRunner.R'
#
# note: defaults assume that getwd is in __misc/debug
#

xlsUnload <- function() dyn.unload( getLoadedDLLs()$xlsReadWritePro[["path"]] )

xlsLoad <- function(root = NA ) .dynLoad(root)

dynTestFunc <- function(filename, test, root = NA){
  root <- .dynSetup(root)
  execTestFile(file.path(root, "inst/unitTests", filename),
               outputDir = file.path(root, "__misc/debug/out"),
               fctname = test)
}

dynTestFile <- function(filename, root = NA){
  root <- .dynSetup(root)
  execTestFile(file.path(root, "inst/unitTests", filename), outputDir = file.path(root, "__misc/debug/out"))
}

dynTestSuite <- function(root = NA){
  root <- .dynSetup(root)
  execTestSuite(file.path(root, "inst/unitTests"), outputDir = file.path(root, "__misc/debug/out"))
}

.dynSetup <- function(root) {
  root <- .dynLoad(root)
  source(file.path(root, "inst/unitTests/runner.R"))
  root
}

.dynLoad <- function( root ){
  if (is.na(root)) {
    stopifnot(basename(getwd()) == "debug")
    root <- file.path(getwd(), "../..")
  }
  if (!is.null(getLoadedDLLs()$xlsReadWritePro)) xlsUnload()
  info <- dyn.load( file.path(root, "src/pas/xlsReadWrite.dll") )
  invisible( apply( cbind( list.files( file.path(root, "R"), full.names = TRUE ) ), 1, source ) )
  root
}

.setupChappi <- function( .root, .clean = FALSE ){
  setwd( file.path( .root, "__misc/debug" ) )

  if (.clean) rm( list = ls(), envir = .GlobalEnv )
  assign( "rfile", file.path( .root, "inst/unitTests/data", "origData.xls" ), envir = .GlobalEnv )
  assign( "wfile", file.path( .root, "__misc/debug/out", "tmpWriteData.xls" ), envir = .GlobalEnv )
  assign( "rfile.img", file.path( .root, "inst/unitTests/data", "origImage.xls" ), envir = .GlobalEnv )
  assign( "wfile.img", file.path( .root, "__misc/debug/out", "tmpImageOut.xls" ), envir = .GlobalEnv )

  xlsLoad()
  library(RUnit)
}
