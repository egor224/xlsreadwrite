###{{ setup

  # xyDir variables from 'runner.R' or define manually in .GlobalEnv
rfile <- file.path( dataDir, "origData.xls" )
wfile <- file.path( outputDir, "tmpWriteData.xls" )

###}}
###{{ test: read rowNames

test.readRowNamesGiven <- function() {
  myrow <- paste( "r", 1:13, sep = "" )
  rdata <- read.xls( rfile, from = 2, rowNames = myrow, type = "double" )
  checkIdentical( rownames( rdata ), myrow )
  rdata <- read.xls( rfile, from = 2, rowNames = myrow, type = "data.frame" )
  checkIdentical( rownames( rdata ), myrow )
}

test.readRowNamesGivenWrong <- function() {
  myrow <- paste( "r", 1:19, sep = "" )
  checkException( read.xls( rfile, from = 2, rowNames = myrow, type = "double" ), silent = TRUE )
  checkException( read.xls( rfile, from = 2, rowNames = myrow, type = "data.frame" ), silent = TRUE )
}

test.readRowlNamesNormal <- function() {
  myrow <- c( "Courtelary", "Delemont", "Franches-Mnt", "Moutier", "Neuveville", 
              "Porrentruy", "Broye", "Glane", "Gruyere", "Sarine", "Veveyse", "Aigle" )
  rdata <- read.xls( rfile, sheet = 5, from = 5, rowNames = TRUE, type = "double" )
  checkIdentical( rownames( rdata ), myrow )
  rdata <- read.xls( rfile, sheet = 5, from = 5, rowNames = TRUE, type = "data.frame" )
  checkIdentical( rownames( rdata ), myrow )
}

###}}