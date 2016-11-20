ALL_MD=$(wildcard *.md)

PWD=$(shell pwd)

all : mds

.PRECIOUS: %.pdf %.tex

mds :	$(ALL_MD:.md=.pdf)

%.tex : %.md paper.pdf logo.png architecture.png
	pandoc --slide-level=2 -V documentclass=paradise-slide -s $< -t beamer -f markdown+raw_tex -o $@ --template=../styles/vlstill/paradiseBeamer/template.tex

%.pdf : %.tex
	rubber --pdf -I "../styles/vlstill/paradiseBeamer/" -o $@ $<

paper.pdf:
	wget -O $@ http://seahorn.github.io/papers/cav15.pdf

logo.png:
	wget -O $@ https://camo.githubusercontent.com/af7ee4ebd07b70a57b295e4d5fd8014d11cbc856/68747470733a2f2f736561686f726e2e6769746875622e696f2f696d616765732f736561686f726e2d6c6f676f2e706e67

architecture.png:
	wget -O $@ http://seahorn.github.io/images/seahorn_arch.png
