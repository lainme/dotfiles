OUTSDIR := outputs
FIGSDIR := figures
MAINOUT := $(patsubst %.tex, %, $(wildcard *.tex))
FIGURES := $(patsubst %.tex, %.eps, $(wildcard $(FIGSDIR)/figures-*.tex))
ARCHIVE := $(wildcard *.cls) $(MAINOUT).tex $(MAINOUT).bib $(MAINOUT).pdf $(wildcard $(FIGSDIR)/figures-*.eps)

all: $(MAINOUT).pdf

$(MAINOUT).pdf: %.pdf: %.tex $(OUTSDIR) $(FIGURES)
	rubber --warn all --into $(OUTSDIR) -m xelatex --shell-escape -q $<
	cp $(OUTSDIR)/$@ .

$(FIGSDIR)/%.eps: $(FIGSDIR)/%.tex
	rubber --into $(OUTSDIR) -m xelatex --shell-escape -q $<
	pdftops -eps $(OUTSDIR)/$*.pdf $@

$(OUTSDIR):
	mkdir -p $@

zip: $(MAINOUT).pdf
	7za a -l -tzip $(MAINOUT).zip $(ARCHIVE)

clean:
	rm -f $(OUTSDIR)/*

.PHONY: clean zip
