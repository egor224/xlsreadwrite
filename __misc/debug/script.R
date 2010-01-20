source( "V:/swissrRepos/public/xlsReadWrite/__misc/dynRunner/dynRunner.R")
setwd( "V:/swissrRepos/public/xlsReadWrite/__misc/debug")
dynTest("testSpecialities.R")
dynTest("testReadWrite.R")

dynTests()

##################

setwd( "V:/swissrRepos/public/xlsReadWrite/inst/RUnitTests/data")
source( "V:/swissrRepos/public/xlsReadWrite/__misc/dynRunner/dynRunner.R")
xlsLoad( "V:/swissrRepos/public/xlsReadWrite/src/pas/xlsReadWrite.dll", "V:/swissrRepos/public/xlsReadWrite/R")
rf1 <- "origData.xls"
rf2 <- "..\\..\\RUnitTests\\data\\origData.xls"
rf3 <- "../../RUnitTests/data/origData.xls"
rdata <- read.xls(rf1)
rdata <- read.xls(rf2)
rdata <- read.xls(rf3)

###################

library(xlsReadWrite)
xls.getshlib(url="file://V:/swissrRepos/public/__gen/bin/xlsReadWrite_0.0.0_dll.zip", md5=F)
wfile <-"V:/swissrRepos/public/xlsReadWrite/__misc/debug/tmpWriteData.xls"

myidx <- c( 1, 19 )
myclsIn <-  c( "integer", "integer", "isodate",   "integer", "integer", "double", "double", "double", "isotime",   "double", "double", "isodatetime"  )
myclsOut <- c( "integer", "integer", "character", "integer", "integer", "double", "double", "double", "character", "double", "double", "character"  )
myval <- data.frame( OleDate = c(38429L, 38460L), AsDate = c(38429L, 38460L), IsoDate = c("2005-03-18", "2005-04-18"), 
                    Hour = c(14L, 11L), Minute = c(42L, 0L), Sec = c(18.005, 31.002), OleTime = c(0.612708391203704, 0.458692152777778), AsTime = c(0.612708391203704, 0.458692152777778), IsoTime = c("14:42:18", "11:00:31"), 
                    OleDateTime = c(38429.6127083912, 38460.4586921528), AsDateTime = c(38429.6127083912, 38460.4586921528), IsoDateTime = c("2005-03-18 14:42:18", "2005-04-18 11:00:31"), stringsAsFactors = FALSE )
rdata <- read.xls( rfile, sheet = "dateTime", colClasses = myclsIn )

for (col in 1:12) class(myval[,col]) <- myclsIn[col]

write.xls( myval, wfile )
