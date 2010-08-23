# execute RUnit tests in '../inst/unitTests'

pkg <- "xlsReadWrite"
shlib <- system.file("libs", if(nzchar(arch <- .Platform$r_arch)) arch,
                     paste(pkg, .Platform$dynlib.ext, sep=""),
                     package = pkg)
stopifnot(file.exists(shlib))

if (file.info(shlib)$size < 20000) {
        ## message appears in the log only
    message("tests not executed (cran placeholder shlib)")
} else if (require("RUnit", quietly = TRUE)) {
    rutdir <- system.file("RUnitTests", package = pkg)
    stopifnot(file.exists(rutdir), file.info(rutdir)$isdir)
    source(system.file("RUnitTests", "runner.R", package = pkg))
    runTestsForCHECK(rutdir)
} else {
    stop("tests not executed ('RUnit' package is required)")
}