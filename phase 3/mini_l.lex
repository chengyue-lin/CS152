%{
#include "y.tab.h"
int cur_line = 1, cur_pos=1;
%}

DIGIT [0-9]
IDENT [a-zA-Z][a-zA-Z0-9_]*[a-zA-Z0-9]
CHAR [a-zA-Z]
E_ID1 [0-9_][a-zA-Z0-9_]*
E_ID2 [a-zA-Z][a-zA-Z0-9_]*[_]
%%

"function"  	{return FUNCTION; cur_pos+=yyleng;}
"beginparams"  	{return BEGIN_PARAMS; cur_pos+=yyleng;}
"endparams"  	{return END_PARAMS; cur_pos+=yyleng;}
"beginlocals"  	{return BEGIN_LOCALS; cur_pos+=yyleng;}
"endlocals"  	{return END_LOCALS; cur_pos+=yyleng;}
"beginbody"  	{return BEGIN_BODY; cur_pos+=yyleng;}
"endbody"  	{return END_BODY; cur_pos+=yyleng;}
"integer"  	{return INTEGER; cur_pos+=yyleng;}
"array"  	{return ARRAY; cur_pos+=yyleng;}
"enum"  	{return ENUM; cur_pos+=yyleng;}
"of"  		{return OF; cur_pos+=yyleng;}
"if"  		{return IF; cur_pos+=yyleng;}
"then"  	{return THEN; cur_pos+=yyleng;}
"endif"  	{return ENDIF; cur_pos+=yyleng;}
"else" 		{return ELSE; cur_pos+=yyleng;}
"while"  	{return WHILE; cur_pos+=yyleng;}
"do"  		{return DO; cur_pos+=yyleng;}
"beginloop"  	{return BEGINLOOP; cur_pos+=yyleng;}
"endloop"  	{return ENDLOOP; cur_pos+=yyleng;}
"continue"  	{return CONTINUE; cur_pos+=yyleng;}
"read"  	{return READ; cur_pos+=yyleng;}
"write"  	{return WRITE; cur_pos+=yyleng;}
"and"  		{return AND; cur_pos+=yyleng;}
"or"  		{return OR; cur_pos+=yyleng;}
"not"  		{return NOT; cur_pos+=yyleng;}
"true"  	{return TRUE; cur_pos+=yyleng;}
"false"  	{return FALSE; cur_pos+=yyleng;}
"return"  	{return RETURN; cur_pos+=yyleng;}
" "		{}

"+"     {return ADD; cur_pos+=yyleng;}
"-"     {return SUB; cur_pos+=yyleng;}
"*"     {return MULT; cur_pos+=yyleng;}
"/"     {return DIV; cur_pos+=yyleng;}
"%"     {return MOD; cur_pos+=yyleng;}


"=="     {return EQ; cur_pos+=yyleng;}
"<>"     {return NEQ; cur_pos+=yyleng;}
"<"      {return LT; cur_pos+=yyleng;}
">"      {return GT; cur_pos+=yyleng;}
"<="     {return LTE; cur_pos+=yyleng;}
">="     {return GTE; cur_pos+=yyleng;}


{DIGIT}+        {yylval.num_val= atoi(yytext); cur_pos+=yyleng;return NUMBER;}
{IDENT}		{yylval.id_val = strdup(yytext); cur_pos+=yyleng;return IDENT;}
{CHAR}		{yylval.id_val = strdup(yytext); cur_pos += yyleng;return IDENT;}
{E_ID1}		{printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", cur_line, cur_pos, yytext); exit(0);}
{E_ID2}		{printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore \n", cur_line, cur_pos, yytext); exit(0);}

";"      {return SEMICOLON; cur_pos+=yyleng;}
":"      {return COLON; cur_pos+=yyleng;}
","      {return COMMA; cur_pos+=yyleng;}
"("      {return L_PAREN; cur_pos+=yyleng;}
")"      {return R_PAREN; cur_pos+=yyleng;}
"["      {return L_SQUARE_BRACKET; cur_pos+=yyleng;}
"]"      {return R_SQUARE_BRACKET; cur_pos+=yyleng;}
":="      {return ASSIGN; cur_pos+=yyleng;}


"##".*"\n"	{cur_line+=1; cur_pos =1;}
[\t]+           {cur_pos+=yyleng;}
"\n"            {cur_line+=1; cur_pos= 1;}


.               {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", cur_line, cur_pos, yytext); exit(0);}


%%


