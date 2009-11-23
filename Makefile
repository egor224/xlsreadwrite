# Makefile for xlsReadWrite
# =========================
#
# use 'flags=<xy>' to pass arguments, e.g.
# - check: 'flags' will be passed on to CHECK ('--no-latex' hard-coded)
# - build: 'flags=--allow-dirty' to build if there are diffs in the workspace


R_VERSION = 2.9.1
include include.mk

.PHONY: pkg check build release
.PHONY: cran check-cran build-cran release-cran

all: temp
temp:
	@cd "$(DBOX)" && $(GIT) --git-dir=../../swissrpkg.git --work-tree=. pull origin
	
# actual (pascal) version
# -----------------------

pkg: check build release
	
check: clean populate
	@echo "### check"
	@cd $(GEN) && $(RCMD) CHECK --no-latex $(flags) $(PKG)
	@$(MAKE) $(W) clean-src
	
build: clean populate $(GENDIR_GEN)
	@echo "### build"
	# update COMMIT file
	@$(GIT) rev-parse HEAD > $(GEN)/$(PKG)/inst/COMMIT
ifneq (,$(findstring --allow-dirty,$(flags))) 
	@HASDIFF="`$(GIT) diff HEAD 2> $(NULL)`" && if (test "$$HASDIFF"); then echo "dirty" >> $(GEN)/$(PKG)/inst/COMMIT; fi
else
	@HASDIFF="`$(GIT) diff HEAD 2> $(NULL)`" && if (test "$$HASDIFF"); then echo "!!! workspace is not clean (commit changes or use '--allow-dirty' flag)" && exit 1; fi
endif
	# src
	@cd $(GEN) && $(RCMD) build $(PKG)
	@mv $(GEN)/$(PKG)_$(PKG_VERSION).tar.gz $(GEN)/src/$(PKG)_$(PKG_VERSION).tar.gz
	# bin
	@cd $(GEN) && $(RCMD) build --use-zip --binary $(PKG)
	@mv $(GEN)/$(PKG)_$(PKG_VERSION).zip $(GEN)/bin/$(PKG)_$(PKG_VERSION).zip
	# shlib
	$(MAKE) -C $(GEN)/$(PKG)/src -f Makevars
	@cd $(GEN)/$(PKG)/src && zip $(PKG)_$(PKG_VERSION)_$(DLL).zip $(PKG).$(DLL) >/dev/null
	@mv $(GEN)/$(PKG)/src/$(PKG)_$(PKG_VERSION)_$(DLL).zip $(GEN)/bin
	# src with shlib
	@mv $(GEN)/$(PKG)/src/$(PKG).$(DLL) $(GEN)/$(PKG)/inst/libs
	@rm -fr $(GEN)/$(PKG)/src
	@cd $(GEN) && $(RCMD) build $(PKG)
	@mv $(GEN)/$(PKG)_$(PKG_VERSION).tar.gz $(GEN)/bin/$(PKG)_$(PKG_VERSION).tar.gz 

# release: $(RELDIR_REL) build
release: $(RELDIR_REL) build
	@echo "### release"
	# src
	@mv $(GEN)/src/$(PKG)_$(PKG_VERSION).tar.gz $(REL)/src
	@$(RSCRIPT) -e "library(tools);write(md5sum('$(REL)/src/$(PKG)_$(PKG_VERSION).tar.gz'), '$(REL)/src/$(PKG)_$(PKG_VERSION).tar.gz.md5.txt')"
	# bin
	@mv $(GEN)/bin/$(PKG)_$(PKG_VERSION).zip $(REL)/bin/$(OS_FOLDER)/$(R_MAJVER)
	@$(RSCRIPT) -e "library(tools);write(md5sum('$(REL)/bin/$(OS_FOLDER)/$(R_MAJVER)/$(PKG)_$(PKG_VERSION).zip'), '$(REL)/bin/$(OS_FOLDER)/$(R_MAJVER)/$(PKG)_$(PKG_VERSION).zip.md5.txt')"
	# shlib
	@mv $(GEN)/bin/$(PKG)_$(PKG_VERSION)_$(DLL).zip $(REL)/bin/$(OS_FOLDER)/shlib
	@$(RSCRIPT) -e "library(tools);write(md5sum('$(REL)/bin/$(OS_FOLDER)/shlib/$(PKG)_$(PKG_VERSION)_$(DLL).zip'), '$(REL)/bin/$(OS_FOLDER)/shlib/$(PKG)_$(PKG_VERSION)_$(DLL).zip.md5.txt')"
	# src with shlib
	@mv $(GEN)/bin/$(PKG)_$(PKG_VERSION).tar.gz $(REL)/bin/$(OS_FOLDER)/src
	@$(RSCRIPT) -e "library(tools);write(md5sum('$(REL)/bin/$(OS_FOLDER)/src/$(PKG)_$(PKG_VERSION).tar.gz'), '$(REL)/bin/$(OS_FOLDER)/src/$(PKG)_$(PKG_VERSION).tar.gz.md5.txt')"
	# update dropbox listing
	cd $(REL) && echo -e "Content of http://dl.dropbox.com/u/2602516/swissrpkg\n" > listing.txt && ls -1Rp >> listing.txt 
	
.PHONY: populate
populate: $(PKGDIR_GEN) $(AUX_GEN) $(SRCPAS_GEN) $(SRCRPAS_GEN)
$(SRCPAS_GEN): $(GEN)/$(PKG)/src/%:$(DEV)/src/pas/%
	@cp $< $@
$(SRCRPAS_GEN): $(GEN)/$(PKG)/src/%:$(DEV)/src/RPascal/src/%
	@cp $< $@

# CRAN version
# ------------

cran: check-cran build-cran release-cran
	
check-cran: clean populatecran
	@echo "### check-cran"
	@cd $(GEN) && $(RCMD) CHECK --no-latex $(flags) $(PKG)
	@$(MAKE) $(W) clean-src

build-cran: clean populatecran $(GENDIR_GEN)
	@echo "### build-cran"
	# update COMMIT file
	@$(GIT) rev-parse HEAD > $(GEN)/$(PKG)/inst/COMMIT
ifneq (,$(findstring --allow-dirty,$(flags))) 
	@HASDIFF="`$(GIT) diff HEAD 2> $(NULL)`" && if (test "$$HASDIFF"); then echo "dirty" >> $(GEN)/$(PKG)/inst/COMMIT; fi
else
	@HASDIFF="`$(GIT) diff HEAD 2> $(NULL)`" && if (test "$$HASDIFF"); then echo "!!! workspace is not clean (commit changes or use '--allow-dirty' flag)" && exit 1; fi
endif
	# src
	@cd $(GEN) && $(RCMD) build $(PKG)
	@mv $(GEN)/$(PKG)_$(PKG_VERSION).tar.gz $(GEN)/src/$(PKG)_$(PKG_VERSION).tar.gz 
	# bin
	@cd $(GEN) && $(RCMD) build --use-zip --binary $(PKG)
	@mv $(GEN)/$(PKG)_$(PKG_VERSION).zip $(GEN)/bin/$(PKG)_$(PKG_VERSION).zip

release-cran: $(RELDIR_REL) build-cran
	@echo "### release-cran"
	# src
	@mv $(GEN)/src/$(PKG)_$(PKG_VERSION).tar.gz $(REL)/cran
	@$(RSCRIPT) -e "library(tools);write(md5sum('$(REL)/cran/$(PKG)_$(PKG_VERSION).tar.gz'), '$(REL)/cran/$(PKG)_$(PKG_VERSION).tar.gz.md5.txt')"
	# bin
	@mv $(GEN)/bin/$(PKG)_$(PKG_VERSION).zip $(REL)/cran/
	@$(RSCRIPT) -e "library(tools);write(md5sum('$(REL)/cran/$(PKG)_$(PKG_VERSION).zip'), '$(REL)/cran/$(PKG)_$(PKG_VERSION).zip.md5.txt')"
	# update dropbox listing
	@cd $(REL) && echo -e "Content of http://dl.dropbox.com/u/2602516/swissrpkg\n" > listing.txt && ls -1Rp >> listing.txt 

.PHONY: populatecran
populatecran: $(PKGDIR_GEN) $(AUX_GEN) $(GEN)/$(PKG)/src/$(SRCC)
$(GEN)/$(PKG)/src/$(SRCC): $(DEV)/src/c/$(SRCC)
	@cp $< $@

# common
# ------

.PHONY: clean clean-src

clean:
	@echo "### clean"
	@rm -rf $(GEN)/*

clean-src:
	@echo "### clean-src"
	@rm -f $(GEN)/$(PKG)/src/*.$(DCU) $(GEN)/$(PKG)/src/*.o $(GEN)/$(PKG)/src/$(PKG).$(DLL) 

$(AUX_GEN): $(GEN)/$(PKG)/%:$(DEV)/%
	@cp $< $@
$(PKGDIR_GEN):
	@mkdir -p $@
$(GENDIR_GEN):
	@mkdir -p $@
$(RELDIR_REL):
	@mkdir -p $@

# Development targets
# -------------------

.PHONY: test-dev compile-dev clean-dev

test-dev:
	@cd $(DEV)/__misc/debugtests && $(RSCRIPT) dynTest.R

c-dev:
	@echo "### compile-c"
	@cd $(DEV)/src/c && $(RCMD) SHLIB $(PKG).c

pas-dev:
	@echo "### compile-pas"
	@$(MAKE) $(W) -C $(DEV)/src/pas -f Makevars

clean-dev:
	@echo "### clean-dev"
	@$(MAKE) $(W) -C $(DEV)/src/pas -f Makevars clean
	@rm -f $(DEV)/src/c/*.o $(DEV)/src/c/$(PKG).$(DLL) 

# Distribution
# ------------

update-dropbox:
	@cd "$(DBOX)" && $(GIT) --git-dir=../../swissrpkg.git --work-tree=. pull origin
