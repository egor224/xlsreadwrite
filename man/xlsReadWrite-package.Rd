\name{xlsReadWrite-package}
\docType{package}
\alias{xlsReadWrite-package}
\alias{xlsReadWrite}
\title{Read and write Excel files}

\description{
    \enumerate{
        \item Overview
        \item RUnit tests
        \item CRAN/pro version
        \item Compile and downloads
        \item Links and contact
    }
}

\section{1. Overview}{
    \code{xlsReadWrite} is a packages which allows to read and write Excel files.
    Currently supported is the .xls (BIFF8) file format.
    \cr

    \bold{Getting started}\itemize{
        \item check out \code{\link{read.xls}}, \code{\link{write.xls}} and \code{\link{xls.getshlib}}
        \item \code{help(package = "xlsReadWrite")} gives information on the package

    }

    \bold{Why xlsReadWrite?}\itemize{
        \item it is fast
        \item well documented and (RUnit) tested
        \item the package does \emph{not} have any external dependencies
        \item it has a nice simple interface and \emph{just works fine} since ~4 years
    }

    On the less rosy side: xlsReadWrite still is windows only and uses proprietary
    3rd party code (which means only our own code is, and can be, free). The package
    is written in Pascal, a very nice language, but a bit obscure in the R world.
    \cr

    \bold{Other solutions and future}

    xlsReadWrite is not the only game in town; we know of the following packages
    (dependencies mentioned in brackets): \emph{RODBC} (drivers), \emph{gdata} (Perl),
    \emph{RExcel} or \emph{COM} (Excel), \emph{dataframes2xls} (Python), \emph{xlsx}
    (Apache POI, Java). Then, of course, using plain old \emph{.csv} files (-) and
    finally our own xlsReadWritePro shareware package, see below.

    xlsReadWrite is mature and no big changes are planned. Some internal
    refactoring would be beneficial and some features could be backported from
    the pro version. In 2011 Delphi should be released for Mac, Linux and Win64,
    and we plan to support these platforms eventually. The underlying library is
    being developed for .xlsx and we are looking forward to it.
}

\section{2. RUnit tests}{
    There are more than 50 unit tests which should cover all aspects of the
    package and ensure and maintain code quality. The tests also serve as an
    extended reference going beyond the examples.

    You can easily run the tests on your system: the RUnit test files are located
    at\cr \code{R_HOME/library/xlsReadWrite/unitTest}.\cr
    Please have a look at the file \code{debug.template.R} for details
    (basically: source file, copy/paste testsuite code).
}

\section{3. CRAN/pro version}{

    Besides the \emph{regular} \code{xlsReadWrite} package there is a special \bold{CRAN}
    version. Reason (copied from the cran version startup message):\cr\cr
"BACKGROUND: Our own xlsReadWrite code is free, but we also use proprietary code"\cr
"(Flexcel, tmssoftware.com) which can only be distributed legally in precompiled,"\cr
"i.e. binary form. As CRAN 'generally does not accept submissions of precompiled"\cr
"binaries due to security reasons' we only provide a placeholder and you can"\cr
"download the binary shlib separately.";\cr

    The \bold{xlsReadWritePro} version is our second attempt and goes further than
    the free version:\itemize{
        \item append data to existing files
        \item work with in-memory Excel 'files' (called xls-obj)\cr
        \item manage sheets (select, insert, copy, rename, delete, hide, info, list)
        \item support images (add, delete, count, list, export, info)
        \item address confined data areas (rows, cols, from, to, (named) ranges, cells)\cr
        \item read and write formula values
        \item get file and sheet related info
        \item more date time helper functions\cr
        \item formal support
    }

    By purchasing the \code{xlsReadWritePro} shareware version you help support
    our development and maintenance effort. We are grateful that quite some people
    and companies did and both, the free and the pro version shall benefit. The
    trial (http://www.swissr.org) is free and the two versions do coexist just fine.
    So, why not check out \code{xlsReadWritePro} now and see for yourself?
}

\section{4. Compile and downloads}{

    Prerequisites for compiling: Delphi 2007 and Flexcel (http://www.tmssoftware.com,
    a high-quality code library for the core Excel-work). Then follow these steps:\enumerate{
        \item Clone the github repo (see below) and initialize the RPascal submodule
        \item Adapt paths in 'include.mk'
        \item Regarding Flexcel code:\itemize{
           \item in FLXCOMPILER.INC: disable the FLEXCEL define, e.g. '{.$DEFINE FLEXCEL}'
           \item 'src/pas/vFlexcelCommits.txt' has the currently used Flexcel version
        }
        \item Run 'make' target in 'cmd.exe' (system path will be modified from
            within our Makefile; running 'make' from 'Terminator' and with cygwin
            only didn't work out (so far))
        \item Alternatively compile/run project in the Delphi IDE.
    }
    
    \bold{Downloads}

    \tabular{rll}{
        All resources:	\tab\tab	    \url{http://dl.dropbox.com/u/2602516/swissrpkg/index.html}\cr
        On CRAN:	    \tab\tab		\url{http://cran.r-project.org/web/packages/xlsReadWrite/index.html}\cr
        Github repo: 	\tab\tab		\url{http://github.com/swissr/xlsReadWrite}\cr
    }
}

\section{5. Links and contact}{

    \tabular{rll}{
        General info:   \tab\tab		\url{http://www.swissr.org} \cr
        Bugtracker:  	\tab\tab		\url{http://dev.swissr.org/projects/xlsReadWrite}\cr
        Forum:          \tab\tab        \url{http://dev.swissr.org/projects/xlsReadWrite/boards}\cr
        Email:          \tab\tab        support at swissr.org\cr
    }

    November 1, 2010 / Hans-Peter
}

\keyword{package}
