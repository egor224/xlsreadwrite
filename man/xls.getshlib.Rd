\name{xls.getshlib}
\alias{xls.getshlib}
\title{Download regular shlib (dll/so)}

\description{
  Downloads regular shlib from swissr dropbox account and replaces
  currently used cran placeholder version. Size: ~420 KB.
}

\usage{
xls.getshlib( pkgvers = NA, url = NA, md5 = TRUE,
              reload.shlib = TRUE, tmpdir = tempdir() )
}

\arguments{
  \item{pkgvers}{optional character string to override the default (which is:
  	(\code{packageDescription( "xlsReadWrite" )$Version})). \option{pkgvers} is 
  	used to replace placeholder in dropbox download url.}
  \item{url}{optional character string to indicate a custom url to the zipped file 
  	containing the shlib. Local, i.e. \code{file://<my url>} urls are possible. If 
  	an url string has been given, the 'pkgvers' argument will not be used.}
  \item{md5}{with \code{TRUE} an md5 value will be retrieved from a file (with 
  	'.md5.txt' suffix) located at the url indicated. A character string is assumed
  	to be the md5 value to be used for checking. \code{FALSE} disables the check.}
  \item{reload.shlib}{\code{TRUE} to replace the loaded (placeholder) library. With
    \code{FALSE} the shlib will only be downloaded (path will be displayed).}
  \item{tmpdir}{temporary folder to downloaded file.}
}

\details{
  The default arguments, i.e. \code{xls.getshlib()}, should work just
  fine. The shlib file is hosted on our swissr dropbox account, see listing at:\cr
  \url{http://dl.dropbox.com/u/2602516/swissrpkg/listing.html}
  
  There have been thorough tests initially but we do not give ANY GUARANTEES AT ALL. You
  might want to revise the 'xls.getshlib' code and/or checkout the package help. In the
  README file you'll find instructions how to compile the package for yourself.
  
  Why do you need to download the shlib from an external source? Two reasons:
  \enumerate{
  \item (copied from the cran version startup message)
  BACKGROUND: Our own xlsReadWrite code is free, but we also use proprietary code
  (Flexcel, tmssoftware.com) which can only be distributed legally in precompiled,
  i.e. binary form. As CRAN 'generally does not accept submissions of precompiled
  binaries due to security reasons' we only provide a placeholder and you can
  download the binary shlib separately.
  \item xlsReadWrite is written in Pascal and cran most probably wouldn't be able/interested to
    support suitable compilers, i.e. Delphi and/or FPC. (We didn't ask about compilers though, 
    because the first point already rules out a normal open source distribution of the package).}
}

\section{Pro version}{
  See section under \link{read.xls}.
}

\seealso{
  \code{\link{read.xls}}, \code{\link{write.xls}}
}

\examples{
\dontrun{
xls.getshlib()
}
}

\keyword{file}
