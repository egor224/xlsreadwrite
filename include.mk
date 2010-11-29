### MAIN LOCATIONS

ROOT=.
DEV=$(ROOT)
GEN=$(ROOT)/../__gen
REL=$(ROOT)/../swissrpkg


### VARIABLES AND SETTINGS

PKG=xlsReadWrite
PKG_VERSION:=$(shell cat $(DEV)/DESCRIPTION | sed -n -e 's/Version: //p')

# switch off directory printing
W=--no-print-directory

NULL="/null"
DCU=dcu
DLL=dll


### DIRECTORIES FOR STORING

# directories in generate folder
GENDIRS=$(addprefix $(GEN)/$(PKG)/, \
    man R src tests inst/unitTests/data inst/template) \
    $(GEN)/bin $(GEN)/src $(GEN)/lib

# directories in release folder
OSDIR=win32
RELDIRS=$(addprefix $(REL)/, \
    bin/$(OSDIR)/src bin/$(OSDIR)/$(R_MAJVER) src)

# listing directory (with generator and template)
LISTING=$(DEV)/__misc/genListing

# dropbox swissrpkg directory
DROPSWISSRPKG=/cygdrive/c/Users/Public/Dropboxen/DropboxSwissr/My Dropbox/Public/swissrpkg

# temp directory (final tests after distribution)
CRANCHECK=/cygdrive/c/Users/chappi/Documents/R/test/crancheck


### FILES

# files in non-source folders
AUX_DEV=$(DEV)/DESCRIPTION $(DEV)/NAMESPACE $(DEV)/LICENSE \
        $(DEV)/tests/execTests.R \
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


### SOFTWARE, INCL. DIRECTORIES

# non-R software
MINGWDIR=/cygdrive/c/Program Files (x86)/R/MinGW/bin
MIKTEXDIR=/cygdrive/c/Program Files (x86)/MiKTex 2.8/miktex/bin
GIT=/cygdrive/c/cygwin/bin/git
LISTINGTOOL=$(LISTING)/genlisting.exe

# R version major, minor splitting
R_MAJVER=$(subst ., ,$(R_VERSION))
R_MAJVER:=$(basename $(R_VERSION))

# !!! R version dependent variables and change system paths !!!
ifneq (,$(findstring 2.12.,$(R_VERSION)))
  # Rtools212 (do not install .dll's (use cygwin libs))
RTOOLS=/cygdrive/c/Program Files/R/Rtools212
RBIN=/cygdrive/c/Program Files/R/R-$(R_VERSION)/bin/i386
RARCH=i386
  # set system path: perl not needed, cygwin has to be at the end!
PATH:=$(RTOOLS)/bin:$(MINGWDIR):$(MIKTEXDIR):/cygdrive/c/cygwin/bin
else
  # RTools211 (works for R2.9 - R2.11; do not install .dll's (use cygwin libs))
RTOOLS=/cygdrive/c/Program Files (x86)/R/Rtools211
RBIN=C:/Program Files (x86)/R/R-$(R_VERSION)/bin
  # set system path: cygwin has to be at the end!
PATH:=$(RTOOLS)/bin:$(RTOOLS)/perl/bin:$(MIKTEXDIR):$(MINGWDIR):/cygdrive/c/cygwin/bin
endif

# R software
RCMD="$(RBIN)/Rcmd.exe"
RGUI="$(RBIN)/Rgui.exe"
RSCRIPT="$(RBIN)/Rscript.exe"


### THIS MAKEFILE RUNS IN CMD.EXE (cygwin) BUT NOT IN TERMINATOR

ifeq (terminator, $(TERM))
$(error does not run in terminator)
endif
ifneq (cygwin, $(TERM))
$(error TERM variable is not cygwin)
endif


### BANNER
# (RTools make version disabled info printing, use warning)

MYMAKE=$(shell which make)
$(info *************************************************)
$(info XLSREADWRITE MAKEFILE)
$(info R:    $(R_VERSION))
$(info Make: $(MYMAKE))
$(info Path: $(PATH))
$(info *************************************************)
