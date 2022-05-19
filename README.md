# 2022-CompilingTheory-Project
2022CompilingTheoryProject for ZJU

### How to run

1. Type `make build`  to build the parser
2. Then type `make test TEST_FILE=xxx.c` to generate Parsing tree file as vis/tree.dot and TAC file in IR/xxx.c.tac .
3. Type `make vis`  to generate .pdf of Parsing tree in vis/
4. Type `make interpret TEST_FILE=xxx.c` to interpret and run the TAC file of the refered .C file
5. Type `make quicksort` and `make matrix` to run the tester for the two given problems. You should first build the parser and generate TAC file for matrix.c/quicksort.c before this step

