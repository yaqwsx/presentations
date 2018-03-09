all : pres.pdf

.PRECIOUS: %.pdf

pres.tex : pres.md paper1.pdf paper2.pdf
	pandoc --slide-level=2 -V documentclass=paradise-slide -s $< -t beamer -f markdown+raw_tex -o $@ --template=../styles/vlstill/paradiseBeamer/template.tex
	sed 's/\\begin{frame}\[fragile\]/\\begin{frame}/' -i $@
	sed 's/\\begin{frame}/\\begin{frame}\[fragile\]/' -i $@

pres.pdf : pres.tex
	rubber --unsafe -c 'setlist arguments -shell-escape'  --pdf -I "../styles/vlstill/paradiseBeamer/" -o $@ $<

paper1.pdf :
	wget http://sro.sussex.ac.uk/69531/1/paper.pdf -O paper1.pdf

paper2.pdf :
	wget http://pages.cs.wisc.edu/~shanlu/paper/res0000020-shi.pdf -O paper2.pdf