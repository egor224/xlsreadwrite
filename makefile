### xlsReadWrite makefile
### note: the makefile modifies the system path (don't want these R specific
### paths permanently in there, not least because of Terminator side-effects).

include rversion.mk 
include include.mk
all:
	@echo "!! Select a specific target !!"

# main targets
.PHONY: build-reg build-cran
.PHONY: check check-reg check-cran 
.PHONY: release release-reg release-cran
.PHONY: distribute test-distributed
# dev and helper targets
.PHONY: test-dev rdconv singledocu-dev docu-dev shlib-c shlib-pas clean-dev
.PHONY: clean-gen clean-gen-src populate-gen-reg populate-gen-cran populate-rel


### reg (regular/pascal version) - build, check, release ######################
###############################################################################

check-reg: clean-gen populate-gen-reg
	@echo "### check-reg ###"
	@cd $(GEN) && $(RCMD) check $(NOARCH) $(flags) $(PKG)
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
	@cd $(GEN) && $(RCMD) INSTALL --library=lib --build $(NOARCH) $(PKG)_$(PKG_VERSION).tar.gz
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
	@$(MAKE) $(W) listing-rel


### cran (CRAN version) - build, check, release ###############################
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
	@HASDIFF="`$(GIT) diff HEAD 2> $(NULL)`" && if (test "$$HASDIFF"); then echo "!!! workspace is not clean (commit changes or use 'flags=--allow-dirty')" && exit 1; fi
endif
	# src
	@cd $(GEN) && $(RCMD) build $(PKG)
	@mv $(GEN)/$(PKG)_$(PKG_VERSION).tar.gz $(GEN)/src/$(PKG)_$(PKG_VERSION).tar.gz 
	# bin
	@cd $(GEN) && $(RCMD) INSTALL --library=lib --build $(NOARCH) $(PKG)_$(PKG_VERSION).tar.gz
	@mv $(GEN)/$(PKG)_$(PKG_VERSION).zip $(GEN)/bin/$(PKG)_$(PKG_VERSION).zip

release-cran: populate-rel build-cran
	@echo "### release-cran ###"
	# src
	@mv $(GEN)/src/$(PKG)_$(PKG_VERSION).tar.gz $(REL)/cran/src
	@$(RSCRIPT) -e "library(tools);write(md5sum('$(REL)/cran/src/$(PKG)_$(PKG_VERSION).tar.gz'), '$(REL)/cran/src/$(PKG)_$(PKG_VERSION).tar.gz.md5.txt')"
	# bin
	@mv $(GEN)/bin/$(PKG)_$(PKG_VERSION).zip $(REL)/cran/$(OSDIR)/$(R_MAJVER)
	@$(RSCRIPT) -e "library(tools);write(md5sum('$(REL)/cran/$(OSDIR)/$(R_MAJVER)/$(PKG)_$(PKG_VERSION).zip'), '$(REL)/cran/$(OSDIR)/$(R_MAJVER)/$(PKG)_$(PKG_VERSION).zip.md5.txt')"
	# generate txt and html listing
	@$(MAKE) $(W) listing-rel


### distribute and final test #################################################
###############################################################################

distribute:
	@echo "### distribute ###"
	# commit files in $(REL)
	@HASDIFF="`cd "$(REL)" && $(GIT) diff HEAD 2> $(NULL)`" && if (test "$$HASDIFF"); then \
	cd "$(REL)" ;\
	$(GIT) add . ;\
	$(GIT) add -u ;\
	$(GIT) commit -m "Commit updated files (distribute target)" ;\
	else \
	echo "Already up-to-date." ;\
	fi
	# push $(REL) to redmine.swissr (new console hack no longer necessary)
	@cd "$(REL)" && $(GIT) push
	# update local swissr dropbox (first commit modifications, i.e. file additions)
	@cd "$(DROPSWISSRPKG)"; HASDIFF="`$(GIT) diff HEAD 2> $(NULL)`"; \
    if (test "$$HASDIFF"); then \
        $(GIT) --git-dir=../../swissrpkg.git --work-tree=. commit -am "Commit updated files (distribute target)"; \
    else \
	    echo "No modifications." ;\
    fi
	@cd "$(DROPSWISSRPKG)" && $(GIT) --git-dir=../../swissrpkg.git --work-tree=. pull origin master

check-distributed-cran:
	@rm -fr $(CRANCHECK)
	@mkdir $(CRANCHECK)
	@cp "$(DROPSWISSRPKG)/cran/src/$(PKG)_$(PKG_VERSION).tar.gz" $(CRANCHECK)
	@cd $(CRANCHECK) && $(RCMD) check $(NOARCH) $(PKG)_$(PKG_VERSION).tar.gz

test-distributed:
# todo:
# * get a certain package version from the swissrpkg folder and install
#   into a R test-lib (version has to be given as argument)
# * cran version: run the getshlib command and execute the RUnit tests
# * regular version: execute the RUnit tests


### development ###############################################################
###############################################################################

# change here but revert afterwards to prevent git changes
# (TYPE=txt and DOCUFILE=xlsReadWrite-package.Rd)
TYPE=txt
DOCUFILE=xlsReadWrite-package
rdconv:
	@echo "### rdconv ###"
	@$(RCMD) Rdconv -t $(TYPE) -o $(DEV)/man/out.$(TYPE) $(DEV)/man/$(DOCUFILE).Rd
singledocu-dev:
	@echo "### singledocu-dev ###"
	@rm -f $(GEN)/$(PKG)/man/$(DOCUFILE).pdf
	@rm -f $(GEN)/$(PKG)/man/$(DOCUFILE).Rd
	@cp $(DEV)/man/$(DOCUFILE).Rd $(GEN)/$(PKG)/man/$(DOCUFILE).Rd
	@cd $(GEN)/$(PKG)/man && $(RCMD) Rd2pdf $(DOCUFILE).Rd
docu-dev: clean-gen populate-gen-reg
	@echo "### docu-dev ###"
	@rm -f $(GEN)/xlsReadWrite.pdf
	@cd $(GEN) && $(RCMD) Rd2pdf $(PKG)

shlib-c:
	@echo "### shlib-c ###"
	@cd $(DEV)/src/c && $(RCMD) SHLIB $(PKG).c
shlib-pas:
	@echo "### shlib-dev ###"
	@$(MAKE) $(W) -C $(DEV)/src/pas -f Makevars
clean-dev:
	@echo "### clean-dev ###"
	@$(MAKE) $(W) -C $(DEV)/src/pas -f Makevars clean
	@rm -f $(DEV)/src/c/*.o $(DEV)/src/c/$(PKG).$(DLL) 

install-dev: clean-gen populate-gen
# todo: not sure about this target
# 	@cd $(GEN) && mkdir "$(GEN)/myRlib" && $(RCMD) INSTALL --library="$(GEN)/myRlib" $(PKG)


### combined and helper #######################################################
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
	@rm -f $(GEN)/$(PKG)/inst/unitTests/execLocal.R
	# copy source file
	@cp $(SRCPAS_DEV) $(GEN)/$(PKG)/src
	@cp $(SRCRPAS_DEV) $(GEN)/$(PKG)/src
populate-gen-cran:
	@echo "### populate-gen-cran ###"
	# make folders
	@mkdir -p $(GENDIRS)
	# copy non source file
	@cp --parents $(AUX_DEV) $(GEN)/$(PKG)
	@rm -f $(GEN)/$(PKG)/inst/unitTests/execLocal.R
	# copy source file
	@cp $(SRCC_DEV) $(GEN)/$(PKG)/src

listing-rel:
	@echo "### listing-rel ###"
	# generate txt listing
	@cd $(REL) && echo -e "# Listing of SwissR' swissrpkg dropbox folder\n# URL root: http://dl.dropbox.com/u/2602516/swissrpkg\n# URL text listing: http://dl.dropbox.com/u/2602516/swissrpkg/listing.txt\n# URL html listing: http://dl.dropbox.com/u/2602516/swissrpkg/index.html\n# More info at: http://www.swissr.org\n" > listing.txt && ls -1rRp >> listing.txt 
	# generate html listing
	@$(LISTINGTOOL) $(REL)/listing.txt $(LISTING)/index.html.template $(REL)/index.html
populate-rel:
	@echo "### populate-rel ###"
	@mkdir -p $(RELDIRS)
