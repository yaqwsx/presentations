ALL_MD=$(wildcard *.md)

PWD=$(shell pwd)

all : mds

.PRECIOUS: %.pdf %.tex

mds :	$(ALL_MD:.md=.pdf)

%.tex : %.md
	pandoc --slide-level=2 -V documentclass=paradise-slide -s $< -t beamer -f markdown+raw_tex -o $@ --template=../styles/vlstill/paradiseBeamer/template.tex

%.pdf : %.tex
	TEXINPUTS=".:../styles/vlstill/paradiseBeamer/:" texfot pdflatex $<
