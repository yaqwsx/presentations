all : pres.pdf

.PRECIOUS: %.pdf

pres.tex : pres.md paper1.pdf paper2.pdf
	pandoc --slide-level=2 -V documentclass=paradise-slide -s $< -t beamer -f markdown+raw_tex -o $@ --template=../styles/vlstill/paradiseBeamer/template.tex
	sed 's/\\begin{frame}\[fragile\]/\\begin{frame}/' -i $@
	sed 's/\\begin{frame}/\\begin{frame}\[fragile\]/' -i $@

pres.pdf : pres.tex
	TEXINPUTS=::../styles/vlstill/paradiseBeamer/ texfot latexmk -shell-escape -halt-on-error --pdf $<
