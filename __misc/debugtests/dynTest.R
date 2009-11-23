# 'dynTest.R'
#
# (see requirements/notes in dynLoad.R)

source( "dynPasLoad.R" )

rutdir <- "../../inst/RUnitTests"
source( file.path( rutdir, "runner.R" ) )
runTests( rutdir )

###############################################################################
# debug code snippets below
if (FALSE) {
runTests( rutdir )
runTest( file.path( rutdir, "testColNames.R" ) )
runTest( file.path( rutdir, "testColNames.R" ), fctname = "test.readColNamesGiven" )
}