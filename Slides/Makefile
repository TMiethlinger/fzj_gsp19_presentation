# Generic Presentation Makefile
# Jülich Supercomputing Centre
# Research Centre Jülich
# Use latexmk to generate pdf automatically
# Use lualatex to support fancy tikz features
# Do not change this file unless you know what you are doing ...

all: prebuilt-slides

include ../common.mk

SOURCES			:= $(wildcard *.tex)
SLIDES			 = $(SOURCES:.tex=)
MODE			?= beamer

.PHONY: prebuilt-slides
prebuilt-slides: $(SLIDES:=.$(MODE).pdf)

.SECONDARY:
.DELETE_ON_ERROR:

.%.$(MODE).tex: Makefile
	/bin/echo '\newcommand{\topdir}{..}' >$@
	/bin/echo '\newcommand{\prebuiltslides}{}' >>$@
ifeq ($(MODE),handout)
	/bin/echo '\newcommand{\handoutoption}{,handout}' >>$@
endif
	/bin/echo '\input{\topdir/header}' >>$@
	/bin/echo '\begin{document}' >>$@
	/bin/echo '\input{$*.tex}' >>$@
	/bin/echo '\end{document}' >>$@

%.pdf: .%.tex
	$(LATEXMK) $(LATEXMK_FLAGS) --jobname=$* --deps-out=$*.dep $<


### Clean target ###
# remove generated files
clean::
	$(LATEXMK_CLEAN)
	$(RM) *.aux *.bbl *.blg
	$(RM) *.vrb *.snm *.nav
	$(RM) *.synctex.gz
	$(RM) *.pgf-plot.gnuplot *.pgf-plot.table
	$(RM) *.x.table *.x.gnuplot
	$(RM) *.dep
	$(RM) .*.tex
	$(RM) $(foreach ext,fdb_latexmk log out toc,$(foreach mode,beamer handout,*.$(mode).$(ext)))
	$(RM) *.pdf
	$(RM) *.auxlock

# Clean up a little bit more
distclean:: clean
	$(LATEXMK_DISTCLEAN)

-include Makefile.local
-include *.dep

ifneq (,$(IGNORE_MISSING))
%::
	@echo "Ignoring missing '$@'"
endif
