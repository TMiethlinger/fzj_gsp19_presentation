TEXHOME			 = $(HOME)/texmf

LATEXMK			 = $(or $(wildcard $(TEXHOME)/bin/latexmk), latexmk)
LATEXMK_FLAGS		 = --lualatex --latexoption="$(LATEXMK_LATEXOPTION)" --bibtex --use-make
LATEXMK_FLAGS		+= $(if $(strip $(VERBOSE)),,--silent)
LATEXMK_FLAGS		+= $(if $(LATEXMK_FORCE_REBUILD),-g)
LATEXMK_FORCE_REBUILD	?=
LATEXMK_LATEXOPTION	 = --interaction=nonstopmode
LATEXMK_LATEXOPTION	+= --synctex=1
LATEXMK_LATEXOPTION	+= --shell-escape
LATEXMK_CLEAN		 = $(LATEXMK) -c
LATEXMK_DISTCLEAN	 = $(LATEXMK) -C
