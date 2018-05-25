ALL_TEX = contravariant.tex
CONTRAVARIANT_TEX = contravariant.tex
CONTRAVARIANT = contravariant.pdf
PDFS = $(CONTRAVARIANT)
LATEX = pdflatex -shell-escape
SPELL = aspell check -len_GB

.PHONY: all spell open clean plots contravariant

all: contravariant

contravariant: $(CONTRAVARIANT)

plots: data
	make -C data

%.pdf: %.tex diagrams/*
	$(LATEX) $<
	$(LATEX) $<
	$(LATEX) $<

re: clean all

spell: $(ALL_TEX)
	for x in $(ALL_TEX) ; do \
	  $(SPELL) $$x ; \
	done

clean:
	rm -rf $(PDFS) *.loc *.toc *.log *.idx *.aux *.out *.nav *.snm *.vrb *.blg *.bbl *.pdf_tex

