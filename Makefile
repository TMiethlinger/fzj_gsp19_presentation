# Guest Student Program 2019 Presentation Makefile
# Jülich Supercomputing Centre
# Research Centre Jülich
# Use latexmk to generate pdf automatically
# Use lualatex to support fancy tikz features
# Do not change this file unless you know what you are doing ...

all: build

include common.mk

GIT		?= git

# Find the .git directory
GITDIR		:= $(shell $(GIT) rev-parse --git-dir)

# defines SOURCE_BASENAME
include name.mk

MODE		?= beamer
TARGET		 = $(SOURCE_BASENAME)
SOURCES		 = $(TARGET:=.tex)


.PHONY: build clean distclean
.DELETE_ON_ERROR:

### Build target ###
build: build-stage0
	$(MAKE) build-stage1

ifneq (,$(wildcard Slides))
build: build-prebuilt-slides
clean:: clean-prebuilt-slides
distclean:: distclean-prebuilt-slides
endif

check-texmf:
	@if [ ! -d "$(TEXHOME)" ]; then echo "FATAL ERROR: $(patsubst $(HOME)/%,~/%,$(TEXHOME)) has not been initialized. Run 'make get-texmf' first."; false; fi

# create gitinfo2 hook
$(GITDIR)/hooks/post-commit: | check-texmf
	$(TEXHOME)/bin/git-gitinfo2 init

# trigger gitinfo2 hook
build-stage0: $(GITDIR)/hooks/post-commit ktikz-template.pgs
	@if [ -z "$(SOURCE_BASENAME)" ]; then echo "INTERNAL ERROR: SOURCE_BASENAME is not defined"; false ; fi
	git checkout

build-stage1: $(TARGET).pdf

build-prebuilt-slides: build-stage0
	$(MAKE) -C Slides

$(TARGET).pdf:
	$(LATEXMK) $(LATEXMK_FLAGS) --deps-out=$(TARGET).dep $(SOURCES)

$(SOURCE_BASENAME).handout.tex:
	/bin/echo '\newcommand{\handoutoption}{,handout}' >$@
	/bin/echo '\input{$(SOURCE_BASENAME)}' >>$@

handout: $(SOURCE_BASENAME).handout.tex
	$(MAKE) SOURCE_BASENAME=$(SOURCE_BASENAME).handout MODE=handout


### Spell checking targets ###

SPELLCHECK_TEX_EXCLUDE	 = Slides/_%.tex %.local.tex
SPELLCHECK_TEX		:= $(filter-out $(SPELLCHECK_TEX_EXCLUDE),$(wildcard *.tex Slides/*.tex))

WORDLIST	 = wordlist.en.pws
ASPELL		 = aspell -l en_US -p ./$(WORDLIST) --extra-dicts=./tex.aspell.dict

%.tex.unkwrd: %.tex $(WORDLIST)
	$(ASPELL) -t list < $< | sort -u > $@

spellcheck-list: $(SPELLCHECK_TEX:=.unkwrd)
	{ $(foreach u,$^,if [ -s $u ]; then echo '*** ${u:.unkwrd=} ***'; cat $u; echo; fi; ) } > spellcheck-report.txt
	head -n 1 $(WORDLIST) > $(WORDLIST).tmp
	tail -n +2 $(WORDLIST) | sort -u >> $(WORDLIST).tmp
	mv $(WORDLIST).tmp $(WORDLIST)
	@echo ============================================================================
	@if [ ! -s spellcheck-report.txt ]; then echo "No spelling problems found."; else cat spellcheck-report.txt; fi

%.tex.chktex: %.tex
	chktex -I0 -q $< | tee $@
	@echo

chktex: $(SPELLCHECK_TEX:=.chktex)


### Clean target ###
# remove generated files
clean::
	$(LATEXMK_CLEAN)
	$(RM) *.aux *.bbl *.blg
	$(RM) *.vrb *.snm *.nav
	$(RM) *.synctex.gz
	$(RM) *.pgf-plot.gnuplot *.pgf-plot.table
	$(RM) *.dep
	$(RM) ktikz-template.pgs
	$(RM) *.unkwrd Slides/*.unkwrd Tutorial/*.unkwrd
	$(RM) *.chktex Slides/*.chktex Tutorial/*.chktex
	$(RM) spellcheck-report.txt

clean-prebuilt-slides:
	$(MAKE) -C Slides clean

# Clean up a little bit more
distclean:: clean
	$(LATEXMK_DISTCLEAN)
	$(RM) $(TARGET).pdf
	$(RM) $(TARGET).handout.pdf $(TARGET).handout.tex
	$(RM) *.auxlock

distclean-prebuilt-slides:
	$(MAKE) -C Slides distclean


# Initial setup: rename t.emplate to f.lastname
t.emplate	 = t.emplate
personalize: SOURCE_BASENAME=$(NAME)
personalize:
	@if [ ! -f "$(t.emplate).tex" ]; then echo "ERROR: This repository was already personalized."; false ; fi
	@if [ -z "$(NAME)" ]; then echo "Usage: make personalize NAME=f.lastname"; false ; fi
	git mv "$(t.emplate).tex" "$(TARGET).tex"
	sed -i "s/$(t.emplate)/$(SOURCE_BASENAME)/g" "name.mk"
	git add "name.mk"
	git commit -m "initial setup for $(SOURCE_BASENAME)"

ktikz-template.pgs: Makefile
	/bin/echo '%\documentclass % or ktikz ignores the template' >$@
	/bin/echo '\def\topdir{$(CURDIR)}' >>$@
	/bin/echo '\input{\topdir/header.tex}' >>$@
	/bin/echo '\begin{document}' >>$@
	/bin/echo '\begin{frame}[plain]' >>$@
	/bin/echo '<>' >>$@
	/bin/echo '\end{frame}' >>$@
	/bin/echo '\end{document}' >>$@

get-texmf:
	test -d $(TEXHOME) || git clone git@gsp.fz-juelich.de:2019/texmf $(TEXHOME)

update-texmf:
	cd $(TEXHOME) && git pull

-include Makefile.local
-include *.dep

ifneq (,$(IGNORE_MISSING))
%::
	@echo "Ignoring missing '$@'"
endif
