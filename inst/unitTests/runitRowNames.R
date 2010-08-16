### test: read write rownames

# (here we only test colnames belonging to double and data.frame types,
#  some non-double type standard colnames tests can be found in runitRadWrite.R)

test.rowNames.true <- function() {
  myrow <- c(42.345, 2.1318527, 5.1960286, 4.0520327, 5.4554428, 0.9201211, 4.3205375, 9.2289868, 3.4951773, 7.162185, 0.0797354, 0.1904384, 6.9478864)
  rdata <- read.xls(rfile, rowNames = TRUE, type = "double")
  checkIdentical(rownames(rdata), as.character(myrow))
  checkEquals(rdata[2,3], -22.6819437)
  write.xls(rdata, wfile, rowNames = TRUE)
  wdata <- read.xls(wfile, type = "double")
  checkIdentical(wdata, rdata)

  rdata <- read.xls(rfile, rowNames = TRUE, type = "data.frame")
  checkIdentical(rownames(rdata), as.character(myrow))
  checkEquals(rdata[2,3], -22.6819437)
  write.xls(rdata, wfile, rowNames = TRUE)
  wdata <- read.xls(wfile, type = "data.frame")
  checkIdentical(wdata, rdata)
}

test.rowNames.given <- function() {
  myrow <- paste("r", 1:13, sep = "")
  rdata <- read.xls(rfile,  rowNames = myrow, type = "double")
  checkIdentical(rownames(rdata), myrow)
  checkEquals(rdata[2,4], -22.6819437)
  write.xls(rdata, wfile, rowNames = myrow)
  wdata <- read.xls(wfile, type = "double")
  checkIdentical(wdata, rdata)

  rdata <- read.xls(rfile,  rowNames = myrow, type = "data.frame")
  checkIdentical(rownames(rdata), myrow)
  checkEquals(rdata[2,4], -22.6819437)
  write.xls(rdata, wfile, rowNames = myrow)
  wdata <- read.xls(wfile, type = "data.frame")
  checkIdentical(wdata, rdata)
}

test.rowNames.readGivenWrong <- function() {
  myval <- 1:4
  myrow <- paste("r", 1:19, sep = "")
  checkException(read.xls(rfile, from = 2, rowNames = myrow, type = "double"), silent = TRUE)
  checkException(write.xls(myval, wfile, rowNames = myrow), silent = TRUE)  
  checkException(read.xls(rfile, from = 2, rowNames = myrow, type = "data.frame"), silent = TRUE)
  checkException(write.xls(as.data.frame(t(myval)), wfile, rowNames = myrow), silent = TRUE)  
}

test.rowNames.givenEmpty <- function() {
  myrow <- as.character(1:3)
  rdata <- rdata.orig <- read.xls(rfile,  sheet = "specialitiesPro", rowNames = TRUE, type = "character", from = 4)
  checkIdentical(rownames(rdata), myrow)
  rownames(rdata) <- NULL
  write.xls(rdata, wfile, rowNames = TRUE)
  wdata <- read.xls(wfile, type = "character")
  checkIdentical(wdata, rdata.orig)

  rdata <- rdata.orig <- suppressWarnings(read.xls(rfile,  sheet = "specialitiesPro", rowNames = TRUE, type = "data.frame", from = 4))
  checkIdentical(rownames(rdata), myrow)
  rownames(rdata) <- NULL
  write.xls(rdata, wfile, rowNames = TRUE)
  wdata <- suppressWarnings(read.xls(wfile, type = "data.frame"))
  checkIdentical(wdata, rdata.orig)
}

test.rowNames.partlyMissing <- function() {
  myrow <- c("1", "formula", "3", "4", "logical", "oledate", "integer", "oletime", "oledatetime",
             "10", "double", "12", "13", "14", "15", "character/factor", "17")
  rdata <- read.xls(rfile,  sheet = "autoCls", rowNames = TRUE, type = "character", from = 2)
  checkIdentical(rownames(rdata), myrow)
}
