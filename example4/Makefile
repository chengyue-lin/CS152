CFLAGS = -g -Wall -ansi -pedantic

phase3: phase3.lex phase3.y
	bison -d -v phase3.y
	flex phase3.lex	
	g++ $(CFLAGS) -std=c++11 lex.yy.c phase3.tab.c -lfl -o phase3
	rm -f lex.yy.c *.output *.tab.c *.tab.h 

test: phase3
	cat ./tests/min/primes.min | ./phase3 > ./tests/mil/primes.mil
	cat ./tests/min/mytest.min | ./phase3 > ./tests/mil/mytest.mil
	cat ./tests/min/fibonacci.min | ./phase3 > ./tests/mil/fibonacci.mil
	cat ./tests/min/errors.min | ./phase3 > ./tests/mil/errors.mil
	cat ./tests/min/for.min | ./phase3 > ./tests/mil/for.mil
