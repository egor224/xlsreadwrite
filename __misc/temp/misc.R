cd V:\swissrRepos\public\xlsReadWrite

setwd( "V:/swissrRepos/public/xlsReadWrite" )
setwd( "V:/swissrRepos/public/xlsReadWrite/__misc/debugtests" )

setwd( "V:/swissrRepos/public/xlsReadWrite/__gen/xlsReadWrite.Rcheck/tests" )

set R=C:\Programme\R\R-2.9.1\bin\R.exe
%R% --no-save

fp <- "../../src/c/xlsReadWrite.dll"; warning( "temp hack" )
xls.getshlib(url="file://D:/DropboxSwissr/My Dropbox/Public/swissrpkg/bin/win32/shlib/xlsReadWrite_1.4.0_dll.zip", pkgvers="1.4.0")

set R=C:\Programme\R\R-2.9.1\bin\R.exe
%R% --help
set RCMD=C:\Programme\R\R-2.9.1\bin\Rcmd.exe
%RCMD% --help
set Rterm=C:\Programme\R\R-2.9.1\bin\Rterm.exe
%Rterm% --help
set Rscript=C:\Programme\R\R-2.9.1\bin\Rscript.exe
%Rscript% --help

set Rscript=C:\Programme\R\R-2.9.1\bin\Rscript.exe
%Rscript% -e 'cat("hello world\n")'

library(tools);write(md5sum("__gen/bin/xlsReadWrite_dll.zip"), "xlsReadWrite_dll.zip.md5.txt")
