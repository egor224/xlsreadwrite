\name{write.xls}
\alias{write.xls}
\title{Write Excel files}

\description{
    Saves a data.frame, matrix or vector as an Excel file.
    Currently supported is the .xls (BIFF8) file format.
}

\usage{
write.xls(x, file,
          colNames = TRUE,
          sheet = 1,
          from = 1,
          rowNames = NA,
          naStrings = "")
}

\arguments{
    \item{x}{data to be written. A data.frame or else a matrix or vector
        of the type double, integer, logical or character. Vectors will
        be written in columns.

        The data (including potential col-/rownames) has to fit into the
        destination area eventually restricted by the \code{from}.}
    \item{file}{name of an Excel file. Path may be absolute or relative
        to the current working directory.}
    \item{colNames}{with \code{TRUE} the data colnames will be written into
        the first row of the sheet or the 'from'-starting area. Provide a character
        vector to write custom colnames. With \code{FALSE} no colnames will be written.
    \item{sheet}{case sensitive character string or one-based number indicating
        the Excel sheet to write to.}
    \item{from}{row to start writing to.}
    \item{rowNames}{with \code{TRUE} the data rownames will be written into
        the first column of the sheet. Provide a character vector to write
        custom rownames. With \code{FALSE} no rownames will be written..}
    \item{naStrings}{the string to be used for \code{NA} values. An empty string
        clears (blanks) the cell, with \code{NA} cell value will not be changed.}
}

\details{
    New files are based on the template \code{TemplateNew.xls} which is located in
    \code{R\_HOME/library/xlsReadWrite/template) or in the application data folder
    \code{<APPDATA>/Treetron/xlsReadWrite}. If both templates exists, the one in the
    application data folder has priority.

    The character string arguments for \code{colNames} and/or \code{colClasses}
    can optionally include an entry for the column used for the rownames (entry
    will be discarded). For \code{rowNames}, the character vector length must be
    the same as the number of data rows.
}

\section{Pro version}{
    See section in \code{\link{read.xls}}.
}

\seealso{
    \code{\link{read.xls}}, \code{\link{write.table}}
}

\examples{\dontrun{
# (without dontrun the CRAN version check would fail)

myval <- data.frame(
    Fertility = c(80.2, 83.1, 92.5), 
    Agriculture = c(17, 45.1, 39.7), 
    Testlogical = c(T,T,F), 
    Education = as.integer(c(12, 9, 5)), 
    Catholic = c(9.96, 84.84, 93.4), 
    Infant.Mortality = c(22.2, 22.2, 20.2), 
    Testcharacter = c("Co", "De", "Fr"), stringsAsFactors = FALSE)
write.xls(myval, "mytest.xls")

mycls <- c("double", "double", "logical", "integer", "double", "double", "character")
wdata <- read.xls("mytest.xls", colClasses = mycls)
rownames(myval) <- as.character(rownames(myval))
stopifnot(identical(wdata, myval))
}}

\keyword{file}
