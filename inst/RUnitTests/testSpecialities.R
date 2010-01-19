### setup

  # xyDir variables from 'runner.R' or define manually in .GlobalEnv
rfile <- file.path( dataDir, "origData.xls" )
wfile <- file.path( outputDir, "tmpWriteData.xls" )


### tests: misc

test.readRKCellValue <- function() {
    # in an old (library) version RKRecord value was not divided by 100
  rdata <- read.xls( rfile, sheet = "specialities", type = "double", from = 12 )[1]
  checkIdentical( rdata, 143.28 )
}

test.read1ColDataFrame <- function() {
  myval <- c( "Courtelary", "Delemont", "Franches-Mnt", "Moutier", "Neuveville", "Porrentruy",
            "", "", "OLD BUG WITH RKRecord:", "143.28" )
  rdata <- read.xls( rfile, FALSE, sheet = "specialities", from = 4, stringsAsFactor = FALSE )
  checkIdentical( rdata[,1], myval )
  
  write.xls( rdata, wfile, colNames = FALSE )
  wdata <- read.xls( wfile, FALSE, stringsAsFactor = FALSE )
  checkIdentical( rdata, wdata )
}  

test.readWithBadFrom <- function() {
	checkException( read.xls( rfile, from = "bad" ), silent = TRUE )
	  # check if wrong type has been catched correctly
	checkEquals( grep( "must be a scalar integer or double", geterrmessage() ), 1 )
}


### tests: relative paths

test.readRelativePathNames <- function() {
    oldwd <- getwd()
    rf1 <- "origData.xls"
      # note: the following two  may fail for non-standard dataDir
    rf2 <- "..\\..\\RUnitTests\\data\\origData.xls"
    rf3 <- "../../RUnitTests/data/origData.xls"
    setwd(dataDir)

    rdata <- read.xls(rf1)
    rdata <- read.xls(rf2)
    rdata <- read.xls(rf3)

    setwd(oldwd)
}
