#
# Makefile for xlsReadWrite
#

# R version (Rversion.mk _not_ in git, warning to force output)
ifneq (,$(findstring Rversion.mk,$(wildcard *.mk))) 
include Rversion.mk 
$(warning ***********************************)
$(warning R version $(R_VERSION) will be used)
$(warning ***********************************)
else
R_VERSION = 2.10.0
endif
	
include include.mk


### list of important targets #################################################
### (use 'flags=<xy>' to pass arguments for check and build) ##################

.PHONY: check release
	
.PHONY: check-reg build-reg release-reg
.PHONY: check-cran build-cran release-cran

.PHONY: push-release

.PHONY: test-dev c-dev pas-dev clean-dev
  

### reg - regular/pascal version ##############################################
###############################################################################

check-reg: clean-gen populate-gen-reg
	@echo "### check-reg ###"
	@cd $(GEN) && $(RCMD) check --no-latex $(flags) $(PKG)
	@$(MAKE) $(W) clean-gen-src
	
build-reg: clean-gen populate-gen-reg $(GENDIR_GEN)
	@echo "### build-reg ###"
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
	@cd $(GEN) && $(RCMD) build --auto-zip --binary $(PKG)
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

release-reg: $(RELDIR_REL) build-reg
	@echo "### release-reg ###"
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
	@cd $(REL) && echo -e "# Listing of SwissR' swissrpkg dropbox folder\n# URL root: http://dl.dropbox.com/u/2602516/swissrpkg\n# URL text listing: http://dl.dropbox.com/u/2602516/swissrpkg/listing.txt\n# URL html listing: http://dl.dropbox.com/u/2602516/swissrpkg/listing.html\n# More info at: http://www.swissr.org\n" > listing.txt && ls -1Rp >> listing.txt 
	# generate html listing
	$(GENLISTEXE) $(REL)/listing.txt $(GENLIST)/listing.html.template $(REL)/listing.html
	
.PHONY: populate-gen
populate-gen-reg: $(PKGDIR_GEN) $(AUX_GEN) $(SRCPAS_GEN) $(SRCRPAS_GEN)
	@echo "### populate-gen-reg"
$(SRCPAS_GEN): $(GEN)/$(PKG)/src/%:$(DEV)/src/pas/%
	@cp $< $@
$(SRCRPAS_GEN): $(GEN)/$(PKG)/src/%:$(DEV)/src/RPascal/src/%
	@cp $< $@


### cran - CRAN version #######################################################
###############################################################################

check-cran: clean-gen populate-gen-cran
	@echo "### check-cran ###"
	@cd $(GEN) && $(RCMD) check --no-latex $(flags) $(PKG)
	@$(MAKE) $(W) clean-gen-src

build-cran: clean-gen populate-gen-cran $(GENDIR_GEN)
	@echo "### build-cran ###"
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
	@cd $(GEN) && $(RCMD) build --auto-zip --binary $(PKG)
	@mv $(GEN)/$(PKG)_$(PKG_VERSION).zip $(GEN)/bin/$(PKG)_$(PKG_VERSION).zip

release-cran: $(RELDIR_REL) build-cran
	@echo "### release-cran ###"
	# src
	@mv $(GEN)/src/$(PKG)_$(PKG_VERSION).tar.gz $(REL)/cran/src
	@$(RSCRIPT) -e "library(tools);write(md5sum('$(REL)/cran/src/$(PKG)_$(PKG_VERSION).tar.gz'), '$(REL)/cran/src/$(PKG)_$(PKG_VERSION).tar.gz.md5.txt')"
	# bin
	@mv $(GEN)/bin/$(PKG)_$(PKG_VERSION).zip $(REL)/cran/$(OS_FOLDER)/$(R_MAJVER)
	@$(RSCRIPT) -e "library(tools);write(md5sum('$(REL)/cran/$(OS_FOLDER)/$(R_MAJVER)/$(PKG)_$(PKG_VERSION).zip'), '$(REL)/cran/$(OS_FOLDER)/$(R_MAJVER)/$(PKG)_$(PKG_VERSION).zip.md5.txt')"
	# update dropbox listing
	@cd $(REL) && echo -e "=== Swissr dropbox ===\n(add folder/files to http://dl.dropbox.com/u/2602516/swissrpkg)\n" > listing.txt && ls -1Rp >> listing.txt 
	# generate html listing
	$(GENLISTEXE) $(REL)/listing.txt $(GENLIST)/listing.html.template $(REL)/listing.html

.PHONY: populate-gen-cran
populate-gen-cran: $(PKGDIR_GEN) $(AUX_GEN) $(GEN)/$(PKG)/src/$(SRCC)
	@echo "### populate-gen-cran"
$(GEN)/$(PKG)/src/$(SRCC): $(DEV)/src/c/$(SRCC)
	@cp $< $@


### development and distribution targets ######################################
###############################################################################

test-dev:
	@echo "### test-dev"
	@cd $(DEV)/__misc/debugtests && $(RSCRIPT) dynTest.R
c-dev:
	@echo "### c-dev"
	@cd $(DEV)/src/c && $(RCMD) SHLIB $(PKG).c
pas-dev:
	@echo "### pas-dev"
	@$(MAKE) $(W) -C $(DEV)/src/pas -f Makevars
clean-dev:
	@echo "### clean-dev"
	@$(MAKE) $(W) -C $(DEV)/src/pas -f Makevars clean
	@rm -f $(DEV)/src/c/*.o $(DEV)/src/c/$(PKG).$(DLL) 

push-release:
	@echo "### push-release ###"
	# commit files in $(REL)
	@HASDIFF="`cd "$(REL)" && $(GIT) diff HEAD 2> $(NULL)`" && if (test "$$HASDIFF"); then \
	cd "$(REL)" ;\
	$(GIT) add . ;\
	&& $(GIT) commit -m "Commit updated files" --author="makefile <push@release>" ;\
	else \
	echo "Already up-to-date." ;\
	fi
	# push $(REL) to redmine.swissr
	@pushexec
	@echo "In new console/process (to avoid 'unable to fork' error)"
	# update local dropbox from $(REL)
	@cd "$(DBOX)" && $(GIT) --git-dir=../../swissrpkg.git --work-tree=. pull origin


### combined & helper #########################################################
###############################################################################

all:
	@echo "!! Select a specific target !!"
check:
	$(MAKE) check-reg
	$(MAKE) check-cran
release:
	$(MAKE) release-reg
	$(MAKE) release-cran

.PHONY: clean-gen clean-gen-src
clean-gen:
	@echo "### clean-gen"
	@rm -rf $(GEN)/*
clean-gen-src:
	@echo "### clean-gen-src"
	@rm -f $(GEN)/$(PKG)/src/*.$(DCU) $(GEN)/$(PKG)/src/*.o $(GEN)/$(PKG)/src/$(PKG).$(DLL) 

$(AUX_GEN): $(GEN)/$(PKG)/%:$(DEV)/%
	@cp $< $@
$(PKGDIR_GEN):
	@mkdir -p $@
$(GENDIR_GEN):
	@mkdir -p $@
$(RELDIR_REL):
	@mkdir -p $@
