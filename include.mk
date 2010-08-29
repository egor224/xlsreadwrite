# include.mk for xlsReadWrite Makefile
# ====================================

# warning because info will not be displayed
$(warning ***********************************)
$(warning R version $(R_VERSION) will be used)
$(warning ***********************************)

### settings

ROOT = .
DEV = $(ROOT)
GEN = $(ROOT)/../__gen
REL = $(ROOT)/../swissrpkg

GENLIST = $(DEV)/__misc/genListing
GENLISTEXE = $(GENLIST)/genlisting.exe
# (ugly, FIXME)
DBOX = "D:/DropboxSwissr/My\ Dropbox/Public/swissrpkg"
DTEMP = "D:/Temp"

# switch off directory printing
W = --no-print-directory

export PKG = xlsReadWrite
PKG_VERSION:= $(shell cat $(DEV)/DESCRIPTION | sed -n -e 's/Version: //p')
R_MAJVER = $(subst ., ,$(R_VERSION))
R_MAJVER := $(basename $(R_VERSION))

  # (ugly, FIXME)
R_HOME = C:/Programme/R/R-$(R_VERSION)
R = $(R_HOME)/bin/R.exe
RCMD = $(R_HOME)/bin/R CMD
RGUI = $(R_HOME)/bin/Rgui.exe
RSCRIPT = $(R_HOME)/bin/Rscript.exe
GIT = C:/Programme/Git/bin/git.exe
NULL = "/null"
# (os_foldername (win32, macosx, debian/lenny))
OS_FOLDER = win32
export DCU = dcu
export DLL = dll


### files and directories

# directories
PKGDIR = man R src tests \
    inst/unitTests/data inst/template
PKGDIR_GEN = $(addprefix $(GEN)/$(PKG)/,$(PKGDIR))
GENDIR_GEN = $(GEN)/bin $(GEN)/src
RELDIR = bin/$(OS_FOLDER)/shlib bin/$(OS_FOLDER)/src \
    bin/$(OS_FOLDER)/$(R_MAJVER) src \
    cran/$(OS_FOLDER)/$(R_MAJVER)
RELDIR_REL = $(addprefix $(REL)/,$(RELDIR))

# files in non-source folders
AUX_DEV = $(DEV) $(DEV)/DESCRIPTION $(DEV)/NAMESPACE \
    $(DEV)/tests/runRUnitTests.R \
    $(DEV)/LICENSE $(DEV)/inst/README \
    $(DEV)/inst/unitTests/Data/origData.xls $(DEV)/inst/template/TemplateNew.xls \
    $(wildcard $(DEV)/inst/unitTests/*.R) \
    $(wildcard $(DEV)/man/*) $(wildcard $(DEV)/R/*)
AUX = $(subst $(DEV)/,,$(AUX_DEV))
AUX_GEN = $(addprefix $(GEN)/$(PKG)/,$(AUX))

# files in source folders
SRCC = $(PKG).c
SRCPAS = $(notdir $(wildcard $(DEV)/src/pas/*.pas))
SRCRPAS = rhR.pas rhRDynload.pas rhRInternals.pas \
    rhxLoadRVars.pas rhxTypesAndConsts.pas
SRCPAS_GEN = $(addprefix $(GEN)/$(PKG)/src/,$(SRCPAS)) $(GEN)/$(PKG)/src/$(PKG).dpr $(GEN)/$(PKG)/src/Makefile $(GEN)/$(PKG)/src/Makevars
SRCRPAS_GEN = $(addprefix $(GEN)/$(PKG)/src/,$(SRCRPAS))

