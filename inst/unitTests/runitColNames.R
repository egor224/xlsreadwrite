### test: read write colNames

# (here we only test colnames belonging to double and data.frame types,
#  some non-double type standard colnames tests can be found in runitRadWrite.R)

test.colNames.given <- function() {
  mycol <- c("one", "two", "three", "four")
  rdata <- read.xls(rfile, colNames = mycol, type = "double", from = 2)
  checkIdentical(colnames(rdata), mycol)
  checkEqualsNumeric(rdata[2,1], 2.13185270174645)
  write.xls(rdata, wfile, colNames = mycol)
  wdata <- read.xls(wfile, type = "double")
  checkIdentical(wdata, rdata)

  rdata <- read.xls(rfile, colNames = mycol, type = "data.frame", from = 2)
  checkIdentical(colnames(rdata), mycol)
  checkEqualsNumeric(rdata[2,1], 2.13185270174645)
  write.xls(rdata, wfile, colNames = mycol)
  wdata <- read.xls(wfile, type = "data.frame")
  checkIdentical(wdata, rdata)
}

test.colNames.givenWrong <- function() {
  myval <- 1:4
  mycol <- c("one", "two")
  checkException(read.xls(rfile, colNames = mycol, type = "double", from = 2), silent = TRUE)
  checkException(write.xls(myval, wfile, colNames = mycol), silent = TRUE)
  checkException(read.xls(rfile, colNames = mycol, type = "data.frame", from = 2), silent = TRUE)
  checkException(write.xls(as.data.frame(t(myval)), wfile, colNames = mycol), silent = TRUE)
}

test.colNames.givenEmpty <- function() {
  rdata <- read.xls(rfile, colNames = TRUE, sheet = "specialities", type = "character", from = 3)
  checkIdentical(colnames(rdata), "V1")
  checkIdentical(rdata[1], "Courtelary")
  colnames(rdata) <- NULL
  write.xls(rdata, wfile, colNames = TRUE)
  wdata <- read.xls(wfile, type = "character", colNames = FALSE)
  checkIdentical(wdata[1,], "V1")
  checkEquals(wdata[-1,,drop = FALSE], rdata, check.attributes = FALSE)

  rdata <- read.xls(rfile, colNames = TRUE, sheet = "specialities", type = "data.frame", from = 3)
  checkIdentical(colnames(rdata), "V1")
  checkIdentical(as.character(rdata[1,1]), "Courtelary")
  colnames(rdata) <- NULL
  write.xls(rdata, wfile, colNames = TRUE)
  wdata <- read.xls(wfile, type = "data.frame", colNames = FALSE)
  checkIdentical(as.character(wdata[1,]), "V1")
  checkEquals(wdata[-1,,drop = FALSE], rdata, check.attributes = FALSE)
}

test.colNames.partlyMissing <- function() {
  mycol <- c("Linktype", "Name.and.Link", "Linkaddress", "V4", "V5", "Col1", "Col2")
  mycol.ex <- c("V1", "Linktype", "Name.and.Link", "Linkaddress", "V5", "V6", "Col1", "Col2")
  rdata <- read.xls(rfile,  sheet = "specialitiesPro", rowNames = TRUE, type = "character", from = 4)
  checkIdentical(colnames(rdata), mycol)
  rdata <- read.xls(rfile,  sheet = "specialitiesPro", rowNames = FALSE, type = "character", from = 4)
  checkIdentical(colnames(rdata), mycol.ex)
  rdata <- read.xls(rfile,  sheet = "specialitiesPro", type = "character", from = 4)
  checkIdentical(colnames(rdata), mycol.ex)
}

test.colNames.numericWithCheckNames <- function() {
  mycol <- c("X42.345", "X3.3950068", "X3.8005233", "X.20.4994424")
  rdata <- read.xls(rfile, colNames = TRUE, type = "double", from = 2)
  checkIdentical(colnames(rdata), mycol)
  checkIdentical(rdata[1,1], 2.1318527)
  write.xls(rdata, wfile, colNames = TRUE)
  wdata <- read.xls(wfile, type = "double", checkNames = FALSE)
  checkIdentical(wdata, rdata)

  rdata <- read.xls(rfile, colNames = TRUE, type = "data.frame", from = 2)
  checkIdentical(colnames(rdata), mycol)
  checkIdentical(rdata[1,1], 2.1318527)
  write.xls(rdata, wfile, colNames = TRUE)
  wdata <- read.xls(wfile, type = "data.frame", checkNames = FALSE)
  checkIdentical(wdata, rdata)
}

test.colNames.numericWithoutCheckNames <- function() {
  mycol <- c("42.345", "3.3950068", "3.8005233", "-20.4994424")
  rdata <- read.xls(rfile, colNames = TRUE, type = "double", from = 2, checkNames = FALSE)
  checkIdentical(colnames(rdata), mycol)
  write.xls(rdata, wfile, colNames = TRUE)
  wdata <- read.xls(wfile, type = "double", checkNames = FALSE)
  checkIdentical(wdata, rdata)

  rdata <- read.xls(rfile, colNames = TRUE, type = "data.frame", from = 2, checkNames = FALSE)
  checkIdentical(colnames(rdata), mycol)
  write.xls(rdata, wfile, colNames = TRUE)
  wdata <- read.xls(wfile, type = "data.frame", checkNames = FALSE)
  checkIdentical(wdata, rdata)
}

test.colNames.withRowNames <- function() {
  mycol <- c("Kol2", "Kol3", "Kol4")
  mycol.all <- c("Kol1", "Kol2", "Kol3", "Kol4")

    # double type
  rdata <- read.xls(rfile, colNames = TRUE, rowNames = TRUE, type = "double")
  checkIdentical(colnames(rdata), mycol)

  write.xls(rdata, wfile, colNames = TRUE, rowNames = TRUE)
  wdata <- read.xls(wfile, type = "double")
  checkIdentical(wdata, rdata)

  write.xls(rdata, wfile, colNames = mycol, rowNames = TRUE)
  wdata <- read.xls(wfile, type = "double")
  checkIdentical(wdata, rdata)

  write.xls(rdata, wfile, colNames = mycol.all, rowNames = TRUE)
  wdata <- read.xls(wfile, type = "double", rowNames = TRUE)
  checkIdentical(wdata, rdata)

    # data.frame type
  rdata <- read.xls(rfile, colNames = TRUE, rowNames = TRUE, type = "data.frame")
  checkIdentical(colnames(rdata), mycol)

  write.xls(rdata, wfile, colNames = TRUE, rowNames = TRUE)
  wdata <- read.xls(wfile, type = "data.frame")
  checkIdentical(wdata, rdata)

  write.xls(rdata, wfile, colNames = mycol, rowNames = TRUE)
  wdata <- read.xls(wfile, type = "data.frame")
  checkIdentical(wdata, rdata)

  write.xls(rdata, wfile, colNames = mycol.all, rowNames = TRUE)
  wdata <- read.xls(wfile, type = "data.frame", rowNames = TRUE)
  checkIdentical(wdata, rdata)
}

test.colNames.withAutoRowNames <- function() {
  mycol <- c("Fertility", "Agriculture", "Testlogical", "Education", "Catholic", "Infant.Mortality", "Testcharacter")
  rdata <- read.xls(rfile, sheet = "dfSht", colNames = TRUE, type = "double", from = 5)
  checkIdentical(colnames(rdata), mycol)
  write.xls(rdata, wfile)
  wdata <- read.xls(wfile, type = "double")
  checkIdentical(wdata, rdata)

  rdata <- read.xls(rfile, sheet = 5, type = "data.frame", from = 5)
  checkIdentical(colnames(rdata), mycol)
  write.xls(rdata, wfile)
  wdata <- read.xls(wfile, type = "data.frame")
  checkIdentical(wdata, rdata)
}
