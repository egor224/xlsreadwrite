### xlsReadWrite makefile
### note: the makefile modifies the system path (don't want these R specific
### paths permanently in there, not least because of Terminator side-effects).

include rversion.mk 
include include.mk
all:
	@echo "!! Select a specific target !!"

# main targets
.PHONY: build-reg build-cran
.PHONY: check check-reg check-cran check-cran-final
.PHONY: release release-reg release-cran push-release
# dev and helper targets
.PHONY: test-dev rdconv singledocu-dev docu-dev shlib-c shlib-pas clean-dev
.PHONY: clean-gen clean-gen-src populate-gen-reg populate-gen-cran populate-rel


### reg - regular/pascal version ##############################################
###############################################################################

check-reg: clean-gen populate-gen-reg
	@echo "### check-reg ###"
	@cd $(GEN) && $(RCMD) check $(flags) $(PKG)
	@$(MAKE) $(W) clean-gen-src
	@echo "### nach check-reg ###"

build-reg: clean-gen populate-gen-reg
	@echo "### build-reg ###"
	# update COMMIT file
	@$(GIT) rev-parse HEAD > $(GEN)/$(PKG)/inst/COMMIT
ifneq (,$(findstring --allow-dirty,$(flags))) 
	@HASDIFF="`$(GIT) diff HEAD 2> $(NULL)`" && if (test "$$HASDIFF"); then echo "dirty" >> $(GEN)/$(PKG)/inst/COMMIT; fi
else
	@HASDIFF="`$(GIT) diff HEAD 2> $(NULL)`" && if (test "$$HASDIFF"); then echo "!!! workspace is not clean (commit changes or use 'flags=--allow-dirty')" && exit 1; fi
endif
 	# src
	@cd $(GEN) && $(RCMD) build $(PKG)
	@cp $(GEN)/$(PKG)_$(PKG_VERSION).tar.gz $(GEN)/src/$(PKG)_$(PKG_VERSION).tar.gz
	# bin
	@cd $(GEN) && $(RCMD) INSTALL --library=lib --build $(PKG)_$(PKG_VERSION).tar.gz
	@mv $(GEN)/$(PKG)_$(PKG_VERSION).zip $(GEN)/bin/$(PKG)_$(PKG_VERSION).zip
	# shlib
	@cd $(GEN)/lib/$(PKG)/libs/$(RARCH) && zip $(PKG)_$(PKG_VERSION)_$(DLL).zip $(PKG).$(DLL) >/dev/null
	@mv $(GEN)/lib/$(PKG)/libs/$(RARCH)/$(PKG)_$(PKG_VERSION)_$(DLL).zip $(GEN)/bin
	# src with shlib
	@rm -fr $(GEN)/$(PKG)/src
	@if test -d $(GEN)/$(PKG)/src*; then echo src file not deleted; exit 1; fi
	@mkdir -p $(GEN)/$(PKG)/inst/libs/$(RARCH)
	@mv $(GEN)/lib/$(PKG)/libs/$(RARCH)/$(PKG).$(DLL) $(GEN)/$(PKG)/inst/libs/$(RARCH)
	@cd $(GEN) && $(RCMD) build $(PKG)
	@mv $(GEN)/$(PKG)_$(PKG_VERSION).tar.gz $(GEN)/bin/$(PKG)_$(PKG_VERSION).tar.gz 

release-reg: populate-rel build-reg
	@echo "### release-reg ###"
	# src
	@mv $(GEN)/src/$(PKG)_$(PKG_VERSION).tar.gz $(REL)/src
	@$(RSCRIPT) -e "library(tools);write(md5sum('$(REL)/src/$(PKG)_$(PKG_VERSION).tar.gz'), '$(REL)/src/$(PKG)_$(PKG_VERSION).tar.gz.md5.txt')"
	# bin
	@mv $(GEN)/bin/$(PKG)_$(PKG_VERSION).zip $(REL)/bin/$(OSDIR)/$(R_MAJVER)
	@$(RSCRIPT) -e "library(tools);write(md5sum('$(REL)/bin/$(OSDIR)/$(R_MAJVER)/$(PKG)_$(PKG_VERSION).zip'), '$(REL)/bin/$(OSDIR)/$(R_MAJVER)/$(PKG)_$(PKG_VERSION).zip.md5.txt')"
	# shlib
	@mv $(GEN)/bin/$(PKG)_$(PKG_VERSION)_$(DLL).zip $(REL)/bin/$(OSDIR)/shlib
	@$(RSCRIPT) -e "library(tools);write(md5sum('$(REL)/bin/$(OSDIR)/shlib/$(PKG)_$(PKG_VERSION)_$(DLL).zip'), '$(REL)/bin/$(OSDIR)/shlib/$(PKG)_$(PKG_VERSION)_$(DLL).zip.md5.txt')"
	# src with shlib
	@mv $(GEN)/bin/$(PKG)_$(PKG_VERSION).tar.gz $(REL)/bin/$(OSDIR)/src
	@$(RSCRIPT) -e "library(tools);write(md5sum('$(REL)/bin/$(OSDIR)/src/$(PKG)_$(PKG_VERSION).tar.gz'), '$(REL)/bin/$(OSDIR)/src/$(PKG)_$(PKG_VERSION).tar.gz.md5.txt')"
	# update dropbox listing
	@cd $(REL) && echo -e "# Listing of SwissR' swissrpkg dropbox folder\n# URL root: http://dl.dropbox.com/u/2602516/swissrpkg\n# URL text listing: http://dl.dropbox.com/u/2602516/swissrpkg/listing.txt\n# URL html listing: http://dl.dropbox.com/u/2602516/swissrpkg/index.html\n# More info at: http://www.swissr.org\n" > listing.txt && ls -1rRp >> listing.txt 
	# generate html listing
	$(LISTINGTOOL) $(REL)/listing.txt $(LISTING)/index.html.template $(REL)/index.html


### cran - CRAN version #######################################################
###############################################################################

check-cran: clean-gen populate-gen-cran
	@echo "### check-cran ###"
	@cd $(GEN) && $(RCMD) check $(flags) $(PKG)
	@$(MAKE) $(W) clean-gen-src

build-cran: clean-gen populate-gen-cran
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

release-cran: populate-rel build-cran
	@echo "### release-cran ###"
	# src
	@mv $(GEN)/src/$(PKG)_$(PKG_VERSION).tar.gz $(REL)/cran/src
	@$(RSCRIPT) -e "library(tools);write(md5sum('$(REL)/cran/src/$(PKG)_$(PKG_VERSION).tar.gz'), '$(REL)/cran/src/$(PKG)_$(PKG_VERSION).tar.gz.md5.txt')"
	# bin
	@mv $(GEN)/bin/$(PKG)_$(PKG_VERSION).zip $(REL)/cran/$(OSDIR)/$(R_MAJVER)
	@$(RSCRIPT) -e "library(tools);write(md5sum('$(REL)/cran/$(OSDIR)/$(R_MAJVER)/$(PKG)_$(PKG_VERSION).zip'), '$(REL)/cran/$(OSDIR)/$(R_MAJVER)/$(PKG)_$(PKG_VERSION).zip.md5.txt')"
	# update dropbox listing
	@cd $(REL) && echo -e "=== Swissr dropbox ===\n(add folder/files to http://dl.dropbox.com/u/2602516/swissrpkg)\n" > listing.txt && ls -1rRp >> listing.txt 
	# generate html listing
	$(LISTINGTOOL) $(REL)/listing.txt $(LISTING)/index.html.template $(REL)/index.html


### development and distribution targets ######################################
###############################################################################

test-dev:
	@echo "### test-dev ###"
	@echo "does not work atm" && exit 1
	//@cd $(DEV)/__misc/debug && $(RSCRIPT) -e "source('../dynRunner/dynRunner.R');dynTests()"


# change here but revert afterwards to prevent git changes
# (TYPE=txt and DOCUFILE=xlsReadWrite-package.Rd)
TYPE=txt
DOCUFILE=xlsReadWrite-package.Rd
rdconv:
	@echo "### rdconv ###"
	@$(RCMD) Rdconv -t $(TYPE) -o $(DEV)/man/out.$(TYPE) $(DEV)/man/$(DOCUFILE)
singledocu-dev:
	@echo "### singledocu-dev ###"
	@rm -f $(GEN)/$(PKG)/man/$(DOCUFILE).pdf
	@rm -f $(GEN)/$(PKG)/man/$(DOCUFILE)
	@cp $(DEV)/man/$(DOCUFILE) $(GEN)/$(PKG)/man/$(DOCUFILE)
	@cd $(GEN)/$(PKG)/man && $(RCMD) Rd2pdf $(DOCUFILE)

docu-dev: clean-gen populate-gen-reg
	@echo "### docu-dev ###"
	@rm -f $(GEN)/xlsReadWrite.pdf
	@cd $(GEN) && $(RCMD) Rd2pdf $(PKG)

shlib-c:
	@echo "### c-dev ###"
	@cd $(DEV)/src/c && $(RCMD) SHLIB $(PKG).c
shlib-pas:
	@echo "### pas-dev ###"
	@$(MAKE) $(W) -C $(DEV)/src/pas -f Makevars
clean-dev:
	@echo "### clean-dev ###"
	@$(MAKE) $(W) -C $(DEV)/src/pas -f Makevars clean
	@rm -f $(DEV)/src/c/*.o $(DEV)/src/c/$(PKG).$(DLL) 

check-cran-final:
	@rm -fr $(DTEMP)/xlsReadWriteCranFinal
	@mkdir $(DTEMP)/xlsReadWriteCranFinal
	@cp $(REL)/cran/src/$(PKG)_$(PKG_VERSION).tar.gz $(DTEMP)/xlsReadWriteCranFinal
	@cd $(DTEMP)/xlsReadWriteCranFinal && $(RCMD) check $(DTEMP)/xlsReadWriteCranFinal/$(PKG)_$(PKG_VERSION).tar.gz

push-release:
	@echo "### push-release ###"
	# commit files in $(REL)
	@HASDIFF="`cd "$(REL)" && $(GIT) diff HEAD 2> $(NULL)`" && if (test "$$HASDIFF"); then \
	cd "$(REL)" ;\
	$(GIT) add . ;\
	&& $(GIT) commit -m "Commit updated files";\
	else \
	echo "Already up-to-date." ;\
	fi
	# push $(REL) to redmine.swissr
	@pushexec
	@echo "In new console/process (to avoid 'unable to fork' error)"
	# update local dropbox from $(REL)
	@cd "$(SWISSRPKG)" && $(GIT) --git-dir=../../swissrpkg.git --work-tree=. pull origin
	@$(MAKE) $(W) check-cran-final


### combined & helper #########################################################
###############################################################################

check:
	$(MAKE) check-reg
	$(MAKE) check-cran
release:
	$(MAKE) release-reg
	$(MAKE) release-cran

clean-gen:
	@echo "### clean-gen ###"
	@rm -rf $(GEN)/*
clean-gen-src:
	@echo "### clean-gen-src ###"
	@rm -f $(GEN)/$(PKG)/src/*.$(DCU) $(GEN)/$(PKG)/src/*.o $(GEN)/$(PKG)/src/$(PKG).$(DLL) 

populate-gen-reg:
	@echo "### populate-gen-reg ###"
	# make folders
	@mkdir -p $(GENDIRS)
	# copy non source file
	@cp --parents $(AUX_DEV) $(GEN)/$(PKG)
	@rm -f $(GEN)/$(PKG)/inst/unitTests/debug.R
	# copy source file
	@cp $(SRCPAS_DEV) $(GEN)/$(PKG)/src/
	@cp $(SRCRPAS_DEV) $(GEN)/$(PKG)/src/
populate-gen-cran:
	@echo "### populate-gen-cran ###"
	# make folders
	@mkdir -p $(GENDIRS)
	# copy non source file
	@cp --parents $(AUX_DEV) $(GEN)/$(PKG)
	@rm -f $(GEN)/$(PKG)/inst/unitTests/debug.R
	# copy source file
	@cp $(SRCC_DEV) $(GEN)/$(PKG)/src/
populate-rel:
	@echo "### populate-rel ###"
	# make folders
	@mkdir -p $(RELDIRS)
