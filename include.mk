###
### note: paths currently refer to my (thinkpad) file/folder layout
###


### MAIN LOCATIONS

ROOT=.
DEV=$(ROOT)
GEN=$(ROOT)/../__gen
REL=$(ROOT)/../swissrpkg


### VARIABLES AND SETTINGS

export PKG=xlsReadWrite
PKG_VERSION:=$(shell cat $(DEV)/DESCRIPTION | sed -n -e 's/Version: //p')

# switch off directory printing
W=--no-print-directory

NULL="/null"
export DCU=dcu
export DLL=dll


### FILES AND DIRECTORIES

# (os_foldername (win32, macosx, debian/lenny))
OS_FOLDER=win32

# generate directories
GENDIR=$(addprefix $(GEN)/$(PKG)/, \
    man R src tests inst/unitTests/data inst/template) \
    $(GEN)/bin

# release directories from ($REL root)
RELDIR=$(addprefix $(REL)/, \
    bin/$(OSDIR)/src bin/$(OSDIR)/$(R_MAJVER) \
    cran/$(OSDIR)/src src)

# listing directory (with generator and template)
LISTINGDIR=$(DEV)/__misc/genListing

# dropbox directory
DBOXDIR=/cygdrive/c/Users/Public/Dropboxen/DropboxSwissr/My Dropbox/Public/swissrpkg

# temp (for cran final test)
DTEMP=/cygdrive/c/Users/chappi/Documents/R/test

# files in non-source folders
AUX_DEV=$(DEV)/DESCRIPTION $(DEV)/NAMESPACE $(DEV)/LICENSE \
        $(DEV)/tests/runRUnitTests.R \
        $(DEV)/inst/template/TemplateNew.xls \
        $(DEV)/inst/unitTests/Data/origData.xls \
        $(wildcard $(DEV)/inst/unitTests/*.R) \
        $(wildcard $(DEV)/man/*) $(wildcard $(DEV)/R/*)

# files in source folders
SRCPAS_DEV=$(wildcard $(DEV)/src/pas/*.pas) \
           $(DEV)/src/pas/$(PKG).dpr \
           $(DEV)/src/pas/Makefile $(DEV)/src/pas/Makevars
SRCRPAS_DEV=$(addprefix $(DEV)/src/RPascal/src/, \
            rhR.pas rhRDynload.pas rhRInternals.pas \
            rhxLoadRVars.pas rhxTypesAndConsts.pas)
SRCC_DEV=$(addprefix $(DEV)/src/c/, $(PKG).c)


### TOOLS INCLUDING VARIABLES THEREOF

# R version major, minor splitting
R_MAJVER=$(subst ., ,$(R_VERSION))
R_MAJVER:=$(basename $(R_VERSION))

# R program folder locations (no 64 bit atm) and exes
ifneq (,$(findstring 2.12.,$(R_VERSION))) 
	R_PROG=/cygdrive/c/Program\ Files/R
	R_BINARCH=bin/i386
else
	R_PROG=/cygdrive/c/Program\ Files\ \(x86\)/R
	R_BINARCH=bin
endif
R_HOME=$(R_PROG)/R-$(R_VERSION)
RCMD=$(R_HOME)/$(R_BINARCH)/Rcmd
RGUI=$(R_HOME)/$(R_BINARCH)/Rgui.exe
RSCRIPT=$(R_HOME)/$(R_BINARCH)/Rscript.exe

MIKTEX=/cygdrive/c/Program Files (x86)/MiKTex 2.8/miktex/bin
GIT=/usr/bin/git


### MODIFY THE PATH

export PATH:=$(RTOOLS)/bin:$(RTOOLS)/perl/bin:$(RMINGW):$(MIKTEX):/usr/bin
