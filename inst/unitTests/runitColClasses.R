# (trivial colClasses have been tested in runitReadWrite.R)

### test: auto-determined colClasses

test.colClasses.autoHasWarnings <- function() {
  mywarn <- 0
  withCallingHandlers(rdata <- read.xls(rfile, sheet = "autoCls", from = 2, stringsAsFactors = FALSE), 
    warning = function(w) { mywarn <<- mywarn + 1; invokeRestart("muffleWarning") })
  checkIdentical(mywarn, 1)
  checkIdentical(class(rdata$just_ok), "character")  
  checkIdentical(rdata$just_ok[16], "world")
  checkIdentical(class(rdata$has_warnings), "logical")  
  checkIdentical(rdata$has_warnings[c(16, 17)], c(NA, NA))
}

test.colClasses.autodetermined.free <- function() {
  # todo
  if (length(grep("cells", names(formals(read.xls)))) == 0) {
                                        # myclsOutClass <-    c("numeric", "numeric", "character", "numeric", "numeric", "numeric", "character")
    myclsOutStorageMode <- c("double", "double", "character", "double", "double", "double", "character")
                                        # TODO: TRUE should be recognized as logical (on pro there is a succession, integer, then character should be detected - ok)
                                        # TODO: Why is the 'Education' not an integer (does this work on pro?)
    rdata <- read.xls(rfile, colNames = TRUE, sheet = "dfSht", from = 5, stringsAsFactors = FALSE)
    checkIdentical(as.vector(sapply(rdata, storage.mode)), myclsOutStorageMode)
  }
}

test.colClasses.autoIncremental.free <- function() {
  # todo
  if (length(grep("cells", names(formals(read.xls)))) == 0) {
        # check first row and then...
      myclsOutClass <- c("factor", rep("numeric", 8), "factor", "logical")
      myclsOutStorageMode <- c("integer", rep("double", 8), "integer", "logical")
      checkIdentical(as.vector(sapply(suppressWarnings(read.xls(rfile, sheet = "autoCls", from = 2)), class)), myclsOutClass)
      checkIdentical(as.vector(sapply(suppressWarnings(read.xls(rfile, sheet = "autoCls", from = 2)), storage.mode)), myclsOutStorageMode)
        # ...loop and check each row separately (on free version)
      mycls <- c("double", "double", rep("character", 4), rep("double", 4), rep("character", 6))
      for (ro in 3:18) {
        checkIdentical(storage.mode(suppressWarnings(read.xls(rfile, colNames = FALSE, sheet = "autoCls", from = ro, stringsAsFactors = FALSE))[,2]), mycls[ro - 2])
      }
   }
}


### test: read write with given colClasses

  # logical, integer, double, character
test.colClasses.readWriteAtom <- function() {
  mycls <-  c("double", "double", "logical", "integer", "double", "double", "character")
  myclsOut <-  c("numeric", "numeric", "logical", "integer", "numeric", "numeric", "character")

  rdata <- read.xls(rfile, colNames = TRUE, "dfSht", from = 5, colClasses = mycls)
  checkIdentical(rdata[[1, 1]], 80.2)
  checkIdentical(colnames(rdata), c("Fertility", "Agriculture", "Testlogical", "Education", "Catholic", "Infant.Mortality", "Testcharacter"))
  checkIdentical(rownames(rdata), c("Courtelary", "Delemont", "Franches-Mnt", "Moutier", "Neuveville", "Porrentruy", "Broye", "Glane", "Gruyere", "Sarine", "Veveyse", "Aigle"))
  checkIdentical(as.vector(sapply(rdata, class)), myclsOut)

  write.xls(rdata, wfile)                         # write cls implicit
  wdata <- read.xls(wfile, colClasses = mycls)
  checkIdentical(wdata, rdata)

  write.xls(rdata, wfile, colClasses = mycls)     # write cls explicit (but same as implicit)
  wdata <- read.xls(wfile, colClasses = mycls)
  checkIdentical(wdata, rdata)

  write.xls(rdata, wfile, colClasses = myclsOut)  # write cls explicit (slightly different from implicit)
  wdata <- read.xls(wfile, colClasses = myclsOut)
  checkIdentical(wdata, rdata)
}

  # isodate, isotime, isodatetime and some <already tested>
test.colClasses.readWriteIso <- function() {
  myval <- data.frame(IntDate = c(38429L, 38460L), AsDate = c(38429L, 38460L), AsIsoDate = c("2005-03-18", "2005-04-18"), 
                      Hour = c(14L, 11L), Minute = c(42L, 0L), Sec = c(18.005, 31.002), IntTime = c(0.612708391203704, 0.458692152777778), AsTime = c(0.612708391203704, 0.458692152777778), AsIsoTime = c("14:42:18", "11:00:31"), 
                      IntDateTime = c(38429.6127083912, 38460.4586921528), AsDateTime = c(38429.6127083912, 38460.4586921528), AsIsoDateTime = c("2005-03-18 14:42:18", "2005-04-18 11:00:31"), stringsAsFactors = FALSE)
  myidx <- c(1, 19)
  mycls <-  c("integer", "integer", "isodate", "integer", "integer", "double", "double", "double", "isotime",   "double", "double", "isodatetime" )
  myclsOut <- list(IntDate = "integer", AsDate = "integer", AsIsoDate = c("isodate", "isodatetime"), 
                   Hour = "integer", Minute = "integer", Sec = "numeric", IntTime = "numeric", AsTime = "numeric", AsIsoTime = c("isotime", "isodatetime"), 
                   IntDateTime = "numeric", AsDateTime = "numeric", AsIsoDateTime = "isodatetime")

  rdata <- read.xls(rfile, sheet = "dateTime", colClasses = mycls)
  for (co in 1:length(myval)) {
    checkEquals(rdata[myidx,co] ,myval[,co])
  }
  checkIdentical(colnames(rdata), colnames(myval))
  checkIdentical(rownames(rdata), as.character(1:19))
  checkIdentical(as.vector(sapply(rdata, class)), myclsOut)

  write.xls(rdata, wfile)                         # write cls implicit
  wdata <- read.xls(wfile, colClasses = mycls)
  checkIdentical(wdata, rdata)

  write.xls(rdata, wfile, colClasses = mycls)     # write cls explicit (but same as implicit)
  wdata <- read.xls(wfile, colClasses = mycls)
  checkIdentical(wdata, rdata)
}

  # NA, factor and some <already tested>
test.colClasses.readWriteNaFactor <- function() {
  myval <- structure(list(
    a = c(TRUE, TRUE),     
    b = structure(1:2, .Label = c("2.8083093", "6.8696548"), class = "factor"), 
    c = c(8.4730313, 4.9871624),
    d = c(-35.3584594, 4.4270298)),
    .Names = c("a", "b", "c", "d"), class = "data.frame", row.names = c(1L, 2L))
  mycls <- c("logical", "factor", "NA", "double")
  myclsOut <- c("logical", "factor", "numeric", "numeric")
  myclsStorage <- c("logical", "integer", "double", "double")

  rdata <- read.xls(rfile, colNames = c("a", "b", "c", "d"), from = 13, colClasses = mycls)
  checkIdentical(as.vector(sapply(rdata, class)), myclsOut)
  checkIdentical(as.vector(sapply(rdata, storage.mode)), myclsStorage)
  checkIdentical(rdata, myval)
}
