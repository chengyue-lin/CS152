CFLAGS = -g -Wall -ansi -pedantic

parse3:  mini_l.lex mini_l.y
	bison -d -v mini_l.y
	flex mini_l.lex
	g++ $(CFLAGS) -std=c++11 mini_l.tab.c lex.yy.c -lfl -o phase3
	rm -f lex.yy.c *.output *.tab.c *.tab.h 
test: phase3
	cat ./mytest.min | ./parser3 > ./mytest.mil
	cat ./primes.min | ./parser3 > ./primes.mil
	cat ./fibonacci.min | ./parser3 > ./fibonacci.mil
	cat ./errors.min | ./parser3 > ./errors.mil
	cat ./for.min | ./parser3 > ./for.mil
clean:
	rm -f lex.yy.c *.output *.tab.c *.tab.h 

