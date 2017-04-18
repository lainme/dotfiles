OUTSDIR := output
FIGSDIR := figure
FIGSRCS := $(wildcard $(FIGSDIR)/*.tex)
DOCSRCS := $(wildcard *.tex)
FIGDEST := $(patsubst %.tex, %.eps, $(FIGSRCS))
DOCDEST := $(patsubst %.tex, %.pdf, $(DOCSRCS))
BIBDEST := $(addprefix $(OUTSDIR)/, $(wildcard *.bib))
ARCHIVE := $(wildcard *.cls *.bib *.tex *.pdf $(FIGSDIR)/*.eps)

all: $(DOCDEST)

$(DOCDEST): %.pdf: %.tex $(OUTSDIR) $(BIBDEST) $(FIGDEST)
	rubber --warn all --into $(OUTSDIR) -m xelatex --shell-escape -q $<
	cp $(OUTSDIR)/$@ .

$(FIGSDIR)/%.eps: $(FIGSDIR)/%.tex
	rubber --into $(OUTSDIR) -m xelatex --shell-escape -q $<
	pdftops -eps $(OUTSDIR)/$*.pdf $@

$(OUTSDIR):
	mkdir -p $@

$(OUTSDIR)/%.bib: %.bib
	cp $< $@

zip: $(DOCDEST)
	7za a -l -tzip archive.zip $(ARCHIVE)

clean:
	rm -f $(OUTSDIR)/*

.PHONY: clean zip
