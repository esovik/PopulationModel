viewer=qlmanage -p
template=templates/template.latex
documents=population.md
pdfs=$(patsubst %.md, %.pdf, $(documents))
font=Georgia
fontsize=12pt
margin=2cm
csl=annual-reviews-author-date

.PHONY: all show clean

all: clean $(pdfs)
ifeq ($(draft),true)
override template=templates/draft-template.latex
endif

show: $(pdfs)
	$(viewer) $< 2>&1>/dev/null &

clean:
	rm -f *.pdf
	rm -f figures/*

$(pdfs): %.pdf: %.md $(template) refs.bib
	cat $< > temp.md
	R CMD BATCH R/simulation.R
	pandoc -o $@ -V geometry:margin=$(margin) \
	--variable fontsize=$(fontsize) \
	--variable mainfont="$(font)" --latex-engine=xelatex \
	--variable lineno \
	--bibliography refs.bib --csl ~/.csl/$(csl).csl \
	--template $(template) temp.md
	perl tools/stripLatex.pl -o temp.md
	pandoc -o README.md \
	--bibliography refs.bib --csl ~/.csl/$(csl).csl \
	temp.md
	rm -rf temp.md temp.md.bak analysis.Rout .RData
