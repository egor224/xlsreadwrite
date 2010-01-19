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
