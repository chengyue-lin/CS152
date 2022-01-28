%{
#include <stdio.h>
#include <stdlib.h>
void yyerror(const char *msg);
extern int cur_line;
extern int cur_pos;
FILE *yyin;
%}

%union{
int num_val; 
char* id_val;

}

%error-verbose
%start start
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE FOR DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN RETURN ENUM
%token <id_val> IDENT
%token <num_val> NUMBER
%right ASSIGN
%left OR
%left AND
%right NOT
%left LT LTE GT GTE EQ NEQ
%left ADD SUB
%left MULT DIV MOD

%%

start:  functions{printf("start -> functions\n");}
        ;

functions:  /*empty*/{printf("functions->epsilo\n");}
        | function functions{printf("functions->function functions\n");}
        ;
    
function:   FUNCTION identifier SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY {printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statement END_BODY \n");}
        ;

declarations:   /*empty*/ {printf("declarations->epsilo\n");}
        | declaration SEMICOLON declarations {printf("declarations->declaration SEMICOLON declarations\n");}
        ;

declaration:    identifiers COLON INTEGER {printf("declaration -> identifiers COLON INTEGER \n");}
        | identifiers COLON ENUM L_PAREN identifiers R_PAREN {printf("declaration -> identifiers COLON ENUM L_PAREN identifiers R_PAREN \n");}
        | identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER \n");}
        ;


identifiers:   identifier {printf("identifiers -> ident\n");}
        | identifier COMMA identifiers {printf("identifiers -> IDENT COMMA identifiers\n");}
        ;

        
identifier:     IDENT {printf("identifier -> IDENT  %s\n", $1);}
                ;


statements:  /*empty*/ {printf("statements ->epsilo\n");}
        | statement SEMICOLON statements {printf("statements -> statement SEMICOLON statements\n");}
        ;

statement:   var ASSIGN expression {printf("statement -> var ASSIGN expression\n");}
        | IF bool_exp THEN statements ELSE statements ENDIF {printf("statement -> IF bool_exp THEN statements ELSE statements ENDIF \n");}
        | IF bool_exp THEN statements ENDIF {printf("statement -> IF bool_exp THEN statements ENDIF \n");}
        | WHILE bool_exp BEGINLOOP statements ENDLOOP {printf("statement -> WHILE bool_exp BEGINLOOP statements ENDLOOP \n");}
        | DO BEGINLOOP statements ENDLOOP WHILE bool_exp {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_exp \n");}
        | READ vars {printf("statement -> READ vars\n");}
        | WRITE vars {printf("statement -> WRITE vars\n");}
        | CONTINUE {printf("statement -> CONTINUE\n");}
        |RETURN expression {printf("statement -> RETURN expression\n");}
        ;

vars:       var {printf("vars -> var\n");}
        | var COMMA vars {printf("vars->var COMMA vars\n");}
        ;

bool_exp:  relation_and_expr {printf("bool_exp -> relation_and_expr\n");}
        |relation_and_expr OR bool_exp {printf("bool_exp -> relation_and_expr OR bool_exp\n");}
        ;

relation_and_expr: relation_expr {printf("relation_and_expr -> relation_expr\n");}
        |relation_expr AND relation_and_expr {printf("relation_and_expr -> relation_expr AND relation_and_expr\n");}
        ;

relation_expr:     expression comp expression {printf("relation_expr -> expression comp expression \n");}
        | NOT expression comp expression {printf("relation_expr -> NOT expression comp expression \n");}
        | TRUE {printf("relation_expr -> TRUE \n");}
        | NOT TRUE {printf("relation_expr ->NOT TRUE \n");}
        | FALSE {printf("relation_expr -> FALSE \n");}
        | NOT FALSE {printf("relation_expr -> NOT FALSE\n");}
        | L_PAREN bool_exp R_PAREN {printf("relation_expr -> L_PAREN bool_exp R_PAREN\n");}
        | NOT L_PAREN bool_exp R_PAREN {printf("relation_expr -> NOT L_PAREN bool_exp R_PAREN\n");}
        ;

comp:   EQ {printf("comp -> EQ\n");}
        | NEQ {printf("comp -> NEQ\n");}
        | LT {printf("comp -> LT\n");}
        | GT {printf("comp -> GT\n");}
        | LTE {printf("comp -> LTE\n");}
        | GTE {printf("comp -> GTE\n");}
        ;

expressions:    expression {printf("expressions -> expression\n");}	
        | expression COMMA expressions {printf("expressions->expression COMMA expressions\n");}
        ;

expression:  multiplicative_expr {printf("expression -> multiplicative_expr\n");}
        | multiplicative_expr ADD expression {printf("expression -> multiplicative_expr ADD expression \n");}
        | multiplicative_expr SUB expression {printf("expression -> multiplicative_expr SUB expression \n");}
        ;

multiplicative_expr:  term {printf("multiplicative_expr -> term\n");}
        | term MOD multiplicative_expr {printf("multiplicative_expr -> term MOD multiplicative_expr\n");}
        | term MULT multiplicative_expr {printf("multiplicative_expr -> term MULT multiplicative_expr\n");}
        | term DIV multiplicative_expr {printf("multiplicative_expr -> term DIV multiplicative_expr\n");}
        ;


term:		  var { printf("term -> var\n"); }
		| SUB var { printf("term -> SUB var\n"); }
		| NUMBER { printf("term -> NUMBER\n"); }
		| SUB NUMBER { printf("term -> SUB NUMBER\n"); }
		| L_PAREN expression R_PAREN { printf("term -> L_PAREN expression R_PAREN\n"); }
		| SUB L_PAREN expression R_PAREN { printf("term -> SUB L_PAREN expression R_PAREN\n"); }
		| identifier L_PAREN R_PAREN { printf("term -> ident L_PAREN R_PAREN\n"); }
		| identifier L_PAREN expressions R_PAREN { printf("term -> ident L_PAREN expressions R_PAREN\n"); }
		;

var:       identifier {printf("var -> identifier\n");}
        | identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("var->identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");}
        ;

%%

int main(int argc, char **argv){
	if(argc >= 2)
        {
                yyin = fopen(argv[1], "r");
                if(yyin == NULL)
                {
                        yyin = stdin;
                }
        }
        else
        {
                yyin = stdin;
        }
	yyparse();
	return 0;
}

void yyerror(const char *msg){
	printf("** Line %d, position %d: %s\n", cur_line, cur_pos, msg);
}
