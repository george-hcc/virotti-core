DOC = main

all: compile
compile:
	@for i in 1 2; do \
	pdflatex -interaction=nonstopmode $(DOC).tex > $(DOC).log; \
	makeindex $(DOC).nlo -s nomencl.ist -o $(DOC).nls; \
	done; 
nls:
	makeindex $(DOC).nlo -s nomencl.ist -o $(DOC).nls
	
compile_error:
	pdflatex -interaction=nonstopmode $(DOC).tex

view:
	evince $(DOC).pdf &

clean:
	rm -rf *.toc
	rm -rf *.log
	rm -rf *.lof
	rm -rf *.lot
	rm -rf *.aux
	rm -rf *.lol
	rm -rf *.ilg
	rm -rf *.nlo
	rm -rf *.nls
	rm -rf *.pdf
	rm -rf *.hst
	rm -rf *.ver
	rm -rf *.out