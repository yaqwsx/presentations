all : pres.pdf

.PRECIOUS: %.pdf

pres.tex : pres.md paper.pdf
	pandoc --slide-level=2 -V documentclass=paradise-slide -s $< -t beamer -f markdown+raw_tex -o $@ --template=../styles/vlstill/paradiseBeamer/template.tex
	# sed 's/\\textbackslash{}begin\\textless{}/\\begin</' -i $@
	# sed 's/\\textgreater{}\\{Shaded\\}/>{Shaded}/' -i $@
	# sed 's/\\textbackslash{}end\\{Shaded\\}/\\end{Shaded}/' -i $@

pres.pdf : pres.tex
	rubber --pdf -I "../styles/vlstill/paradiseBeamer/" -o $@ $<

paper.pdf :
	wget http://drona.csa.iisc.ernet.in/~deepakd/tpa-2016/C2BP.pdf -O paper.pdf