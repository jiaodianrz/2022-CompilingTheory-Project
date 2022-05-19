.PHONY:vis
SYMBOL = .tac
build:
	flex -o src/lex.yy.c src/parser.l
	bison -o src/parser.tab.c src/parser.y
	gcc -g src/parser.tab.c -ll -ly -o parser

test:
	./parser src/test/$(TEST_FILE)
	
interpret:
	python IR/interpreter.py IR/$(TEST_FILE)$(SYMBOL)

vis:
	python vis/vis.py

matrix:
	./IR/Matrix/linux-amd64 ./IR/Matrix/vim.sh

quicksort:
	./IR/quicksort/linux-amd64 ./IR/quicksort/vim.sh

clean:
	rm -rf src/lex.yy.c src/parser.tab.c parser Source.gv Source.gv.pdf
	rm -rf IR/*.tac
	rm -rf vis/*.dot