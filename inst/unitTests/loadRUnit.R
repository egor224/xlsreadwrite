# loads RUnit and provides helper functions to execute tests

### manual execution by USER (see debug.template.R)

  # execute *all* testfiles in 'runitDir' folder
execTestSuite <- function(runitDir, outDir = runitDir) {
  suite <- defineTestSuite(name = "RUnit tests", dirs = runitDir, testFileRegex = "^runit[[:upper:]].+\\.[rR]$")
  invisible(sapply(dir(file.path(runitDir, runitDir), full.names = TRUE), load, envir = parent.frame()))
  res <<- runTestSuite(suite)
  .printResults(res, outDir)
}

  # execute 'testfile' with all or one single 'fctname' functions
execTestFile <- function(testfile, fctname = NA, outDir = NA) {
  runitDir <- dirname(testfile)
  fct <- if (is.na(fctname)) "^test.+" else paste("^", fctname, "$", sep = "")
  if (is.na(outDir)) outDir <- runitDir
  invisible(sapply(dir(file.path(runitDir, runitDir), full.names = TRUE), load, envir = parent.frame()))
  res <- runTestFile(testfile, testFuncRegexp = fct)
  .printResults(res, outDir)
}

### executed from within R CMD CHECK

execTestSuiteCHECK <- function(runitDir) {
  pkg <- sub("\\.Rcheck$", '', basename(dirname(getwd())))
  library(package = pkg, character.only = TRUE)
  data(askPrice, bidPrice, fill, order, tick)

  suite <- defineTestSuite(name = paste(pkg, "RUnitTests called from CHECK"), dirs = runitDir, testFileRegex = "^runit[[:upper:]].+\\.[rR]$")
  res <- runTestSuite(suite)
  tmp <- getErrors(res)
  hasErrors <- tmp$nFail > 0 || tmp$nErr > 0
  if (hasErrors) {
    # warnings won't be displayed, we have to stop
    stop("RUnitTests failed:\n  -> ", tmp$nFail, " failure(s), ", tmp$nErr, " error(s)\n",
         "  -> details in <pkg>.Rcheck/tests/execRUnit.Rout.fail")
  }
}

### helper function

.printResults <- function(res, outDir) {
  printTextProtocol(res, showDetails = FALSE, fileName = file.path(outDir, "_Results.txt"))
  printTextProtocol(res, showDetails = TRUE, fileName = file.path(outDir, "_Details.txt"))
  tmp <- getErrors(res)
  hasErrors <- tmp$nFail > 0 || tmp$nErr > 0
  if (hasErrors) {
    message("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n")
    message("RUnit test _not_ ok:\n")
    message(tmp$nFail, " failure(s), ", tmp$nErr, " error(s), ", tmp$nDeactivated, " deactivated, ",
            tmp$nTestFunc - tmp$nFail - tmp$nErr, " successful\n")
    message("(Log: ", normalizePath(outDir), ")\n")
    message("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n")
  } else {
    message("\n")
    message("RUnit test ok: ", tmp$nTestFunc, " test function(s), ", tmp$nDeactivated, " deactivated\n")
    message("(Log: ", normalizePath(outDir), ")\n")
  }
}

### setup and global settings

.setupFilenames <- function(runitDir, outDir = runitDir){
  assign("rfile", file.path(runitDir, "data/origData.xls"), envir = .GlobalEnv)
  assign("rfile.img", file.path(runitDir, "data/origImage.xls"), envir = .GlobalEnv)
  assign("wfile", file.path(outDir, "tmpWriteData.xls"), envir = .GlobalEnv)
  assign("wfile.img", file.path(outDir, "tmpImageOut.xls"), envir = .GlobalEnv)
}

library(RUnit)
library(tools)

