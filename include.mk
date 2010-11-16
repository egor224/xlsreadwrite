### MAIN LOCATIONS

export ROOT=.
export DEV=$(ROOT)
export GEN=$(ROOT)/../__gen
export REL=$(ROOT)/../swissrpkg


### VARIABLES AND SETTINGS

export PKG=xlsReadWrite
export PKG_VERSION:=$(shell cat $(DEV)/DESCRIPTION | sed -n -e 's/Version: //p')

# switch off directory printing
export W=--no-print-directory

export NULL="/null"
export DCU=dcu
export DLL=dll


### DIRECTORIES FOR STORING

# directories in generate folder
export GENDIRS=$(addprefix $(GEN)/$(PKG)/, \
    man R src tests inst/unitTests/data inst/template) \
    $(GEN)/bin $(GEN)/src $(GEN)/lib

# directories in release folder
export OSDIR=win32
export RELDIRS=$(addprefix $(REL)/, \
    bin/$(OSDIR)/src bin/$(OSDIR)/$(R_MAJVER) \
    cran/$(OSDIR)/src src)

# listing directory (with generator and template)
export LISTING=$(DEV)/__misc/genListing

# dropbox swissrpkg directory
export SWISSRPKG=$(C)/Users/Public/Dropboxen/DropboxSwissr/My Dropbox/Public/swissrpkg

# temp directory (for cran final test)
export DTEMP=$(C)/Users/chappi/Documents/R/test


### FILES

# files in non-source folders
export AUX_DEV=$(DEV)/DESCRIPTION $(DEV)/NAMESPACE $(DEV)/LICENSE \
        $(DEV)/tests/execTests.R \
        $(DEV)/inst/template/TemplateNew.xls \
        $(DEV)/inst/unitTests/Data/origData.xls \
        $(wildcard $(DEV)/inst/unitTests/*.R) \
        $(wildcard $(DEV)/man/*) $(wildcard $(DEV)/R/*)

# files in source folders
export SRCPAS_DEV=$(wildcard $(DEV)/src/pas/*.pas) \
           $(DEV)/src/pas/$(PKG).dpr \
           $(DEV)/src/pas/Makefile $(DEV)/src/pas/Makevars
export SRCRPAS_DEV=$(addprefix $(DEV)/src/RPascal/src/, \
            rhR.pas rhRDynload.pas rhRInternals.pas \
            rhxLoadRVars.pas rhxTypesAndConsts.pas)
export SRCC_DEV=$(addprefix $(DEV)/src/c/, $(PKG).c)


### SOFTWARE, INCL. DIRECTORIES

# non-R software
export MINGWDIR=/cygdrive/c/Program Files (x86)/R/MinGW/bin
export MIKTEXDIR=/cygdrive/c/Program Files (x86)/MiKTex 2.8/miktex/bin
export GIT=/cygdrive/c/cygwin/bin/git
export LISTINGTOOL=$(LISTING)/genlisting.exe

# R version major, minor splitting
export R_MAJVER=$(subst ., ,$(R_VERSION))
export R_MAJVER:=$(basename $(R_VERSION))

# R version dependent variables and system paths
ifneq (,$(findstring 2.12.,$(R_VERSION)))
  # Rtools212 (do not install .dll's (use cygwin libs))
export RTOOLS=/cygdrive/c/Program Files/R/Rtools212
export RBIN=/cygdrive/c/Program Files/R/R-$(R_VERSION)/bin/i386
export RARCH=i386
  # set system path: perl not needed, cygwin has to be at the end!
export PATH:=$(RTOOLS)/bin:$(MINGWDIR):$(MIKTEXDIR):/cygdrive/c/cygwin/bin
else
  # RTools211 (works for R2.9 - R2.11; do not install .dll's (use cygwin libs))
export RTOOLS=/cygdrive/c/Program Files (x86)/R/Rtools211
export RBIN=C:/Program Files (x86)/R/R-$(R_VERSION)/bin
  # set system path: cygwin has to be at the end!
export PATH:=$(RTOOLS)/bin:$(RTOOLS)/perl/bin:$(MIKTEXDIR):$(MINGWDIR):/cygdrive/c/cygwin/bin
endif

# R software
export RCMD="$(RBIN)/Rcmd.exe"
export RGUI="$(RBIN)/Rgui.exe"
export RSCRIPT="$(RBIN)/Rscript.exe"


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
