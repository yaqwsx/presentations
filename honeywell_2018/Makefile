ALL_MD=$(wildcard *.md)

PWD=$(shell pwd)

all : mds

.PRECIOUS: %.pdf

mds :	$(ALL_MD:.md=.pdf)

%.tex : %.md
	pandoc --slide-level=2 -V documentclass=paradise-slide -s $< -t beamer -f markdown+raw_tex+smart -o $@ --template=../styles/vlstill/paradiseBeamer/template.tex

%.pdf : %.tex
	rubber --pdf -I "../styles/vlstill/paradiseBeamer/" -o $@ $<
