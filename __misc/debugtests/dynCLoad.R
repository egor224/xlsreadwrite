# 'dynRun.R'
#
# ('getwd()' is supposed to be '__misc/debugtests')


if (FALSE) {
	  # snippets for manual execution
	setwd( "V:/swissrRepos/public/xlsReadWrite/__misc/debugtests" )
	source( "dynCLoad.R" )
	xls.getshlib(pkgvers="1.4.0")
}

dll <- "../../src/c/xlsReadWrite.dll"
rsrc <- "../../R"
if (!is.null( getLoadedDLLs()$xlsReadWrite )) dyn.unload( dll )
info <- dyn.load( dll )
invisible( apply( cbind( list.files( rsrc, full.names = TRUE ) ), 1, source ) )
