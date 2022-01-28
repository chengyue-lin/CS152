%{
#define YY_NO_UNPUT
#include <stdio.h>
#include <stdlib.h>
#include <map>
#include <string.h> 
#include <set>

int tempCount= 0;
int labelCount= 0;
extern char* yytext;
extern int currPos;
void yyerror(const char *s);
int yylex();
extern int cur_line;
extern int cur_pos;
bool mainFunc = false;

FILE *yyin;
std::set<std::string> reserved {"NUMBER", "IDENT", "RETURN", "FUNCTION", "SEMICOLON", "BEGIN_PARAMS", "END_PARAMS", "BEGIN_LOCALS", "END_LOCALS", "BEGIN_BODY", 
    "END_BODY", "BEGINLOOP", "ENDLOOP", "COLON", "INTEGER", "COMMA", "ARRAY", "L_SQUARE_BRACKET", "R_SQUARE_BRACKET", "L_PAREN", "R_PAREN", "IF", "ELSE", "THEN", 
    "CONTINUE", "ENDIF", "OF", "READ", "WRITE", "DO", "WHILE", "FOR", "TRUE", "FALSE", "ASSIGN", "EQ", "NEQ", "LT", "LTE", "GT", "GTE", "ADD", "SUB", "MULT", "DIV", 
    "MOD", "AND", "OR", "NOT", "Function", "Declarations", "Declaration", "Vars", "Var", "Expressions", "Expression", "Idents", "Ident", "Bool-Expr", 
    "Relation-And-Expr", "Relation-Expr-Inv", "Relation-Expr", "Comp", "Multiplicative-Expr", "Term", "Statements", "Statement"};



std::string new_temp();
std::string new_label();
std::set <std::string> funcs;
std::set<std::string, int> arrSize;
std::map<std::string, std::string> varTemp;
%}


%union{
int num_val; 
char* id_val;
struct S {
   char* code;
} statement;
struct E {
   char* place;
   char* code;
   bool arr;
} expression;
}

%error-verbose
%start functions
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE FOR DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN RETURN ENUM
%token <id_val> IDENT
%token <num_val> NUMBER
%type <expression> function identifier declaration declarations identifiers vars var expression expressions functions
%type <expression> bool_exp relation_and_expr relation_expr comp multiplicative_expr term FuncIdent 
%type <statement> statement statements
%right ASSIGN
%left OR
%left AND
%right NOT
%left LT LTE GT GTE EQ NEQ
%left ADD SUB
%left MULT DIV MOD

%%



functions:  /*empty*/
{       
        if(!mainFunc){
                printf("No main function declared! \n");
                exit(0);
        }
}
        | function functions
        {

        }
        ;
    
function:   FUNCTION FuncIdent SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY 
        {
                std::string temp = "func ";
                temp.append($2.place);
                temp.append("\n");
                std::string s = $2.place;
                if (s == "main"){
                        mainFunc = true;
                }
                temp.append($5.code);
                std::string dec = $5.code;
                int decnum = 0;
                while(dec.find(".") != std::string::npos) {
                        int pos = dec.find(".");
                        dec.replace(pos, 1, "=");
                        std::string part =", $" +std::to_string(decnum) + "\n";
                        decnum++;
                        dec.replace(dec.find("\n", pos), 1, part);
                }
                temp.append(dec);

                temp.append($8.code);
                std::string statements = $11.code;
                if(statements.find("continue") != std::string::npos){
                        printf("ERROR: Continue outside loop in function %s\n", $2.place);
                        exit(0);
                }
                temp.append(statements);
                temp.append("endfunc\n\n");
                printf(temp.c_str());
        }
        ;

declarations:   
        declaration SEMICOLON declarations 
        {
                std::string temp;
                temp.append($1.code);
                temp.append($3.code);
                $$.code = strdup(temp.c_str());
                $$.place = strdup("");
        }
        |/*empty*/ 
        {
                $$.place = strdup("");
                $$.code = strdup("");
        }
        ;

declaration:    identifiers COLON INTEGER 
        {
                int left= 0;
                int right =0;
                std::string parse($1.place);
                std::string temp;
                bool ex = false;
                while(!ex) {
                        right = parse.find("|", left);
                        temp.append(". ");
                        if(right == std::string::npos){
                                std::string ident = parse.substr(left, right);
                                if(reserved.find(ident) != reserved.end()){
                                        printf("identifier %s's name is a reserved word.\n", ident.c_str());
                                }
                                if(funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end()){
                                        printf("Identifier %s is previously declared.\n", ident.c_str());
                                }else {
                                        varTemp[ident] = ident;
                                        arrSize[ident] = 1; 
                                }
                                temp.append(ident);
                                ex = true;
                        }
                        else{
                                std::string ident = parse.substr(left, right-left);
                                 if(reserved.find(ident) != reserved.end()){
                                        printf("identifier %s's name is a reserved word.\n", ident.c_str());
                                }
                                if(funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end()){
                                        printf("Identifier %s is previously declared.\n", ident.c_str());
                                }else {
                                        varTemp[ident] = ident;
                                        arrSize[ident] = 1; 
                                }
                                temp.append(ident);
                                left = right +1;
                        }
                        temp.append("\n");
                }
                $$.code = strdup(temp.c_str());
                $$.place = strdup("");
        }      
        | identifiers COLON ENUM L_PAREN identifiers R_PAREN  //extra credit Not sure about this one. 
        {
              
        }

        | identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER 
        {
                int left =0;
                int right = 0;
                std::string parse($1.place);
                std::string temp;
                bool ex = false;
                while(!ex) {
                        right = parse.find("|", left);
                        temp.append(".[] ");
                        if(right == std::string::npos){
                                std::string ident = parse.substr(left, right);
                                if(reserved.find(ident) != reserved.end()){
                                        printf("identifier %s's name is a reserved word.\n", ident.c_str());
                                }
                                if(funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end()){
                                        printf("Identifier %s is previously declared.\n", ident.c_str());
                                }else {
                                        if($5<=0){
                                                printf("Declaring array ident $s of size <= 0.\n", ident.c_str());
                                        }
                                        varTemp[ident] = ident;
                                        arrSize[ident] = $5; 
                                }
                                temp.append(ident);
                                ex = true;
                        }else {
                                std::string ident = parse.substr(left, right-left);
                                 if(reserved.find(ident) != reserved.end()){
                                        printf("identifier %s's name is a reserved word.\n", ident.c_str());
                                }
                                if(funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end()){
                                        printf("Identifier %s is previously declared.\n", ident.c_str());
                                }else {
                                        if( $5<= 0){
                                                printf("Declaring array ident $s of size <= 0.\n", ident.c_str());
                                        }
                                        varTemp[ident] = ident;
                                        arrSize[ident] = $5; 
                                }
                                temp.append(ident);
                                left = right +1;
                        }
                        temp.append(", ");
                        temp.append(std::to_string($5));
                        temp.append("\n");
                }
                $$.code = strdup(temp.c_str());
                $$.place = strdup("");
        }
        ;
FuncIdent: IDENT
        {
                 if(funcs.find($1) != funcs.end()){
                        printf("function name $s already declared.\n", $1);
                } else{
                        funcs.insert($1);
                }
                $$.place = strdup($1);
                $$.code = strdup("");
        }
        ;
identifier:      IDENT 
    {
        $$.place = strdup($1);
        $$.code = strdup("");
    }
    ;
identifiers:   identifier 
        {
                $$.place = strdup($1.place);
                $$.code = strdup("");
        }
        | identifier COMMA identifiers 
        {
                std::string temp;
                temp.append($1.place);
                temp.append("|");
                temp.append($3.place);
                $$.place = strdup(temp.c_str());
                $$.code = strdup("");
        }
        ;



statements:  /*empty*/ 
        {
                $$.place = strdup("");
                $$.code = strdup("");
        }
        | statement SEMICOLON statements 
        {
                std::string temp;
                temp.append($1.code);
                temp.append($3.code);
                $$.code = strdup(temp.c_str());
                $$.place = strdup("");
        }
        ;

statement:   var ASSIGN expression 
        {
                std::string temp;
                temp.append($1.code);
                temp.append($3.code);
                std::string middle = $3.place;
                if($1.arr && $3.arr){
                        temp+= "[]= ";
                } else if($1.arr){
                        temp += "[]= ";
                } else if ($3.arr){
                        temp+="= ";
                } else {
                        temp+="= ";
                }
                temp.append($1.place);
                temp.append(", ");
                temp.append(middle);
                temp += "\n";
                $$.code = strdup(temp.c_str());
        }
        | IF bool_exp THEN statements ELSE statements ENDIF 
        {
                std::string ifs = new_label();
                std::string after = new_label();
                std::string temp;
                temp.append($2.code);
                temp = temp + "?:= " + ifs + ", " +$2.place+"\n";
                temp.append($6.code);
                temp = temp + ":= " + after + "\n";
                temp = temp +": "+ifs + "\n";
                temp.append($4.code);
                temp = temp + ": "+ after + "\n";
                $$.code = strdup(temp.c_str());
        }
        | IF bool_exp THEN statements ENDIF 
        {
                std::string ifs = new_label();
                std::string after = new_label();
                std::string temp;
                temp.append($2.code);
                temp = temp + "?:= " + ifs + ", " +$2.place+"\n";
                temp = temp + ":= " + after + "\n";
                temp = temp +": "+ifs + "\n";
                temp.append($4.code);
                temp = temp + ": "+ after + "\n";
                $$.code = strdup(temp.c_str());
        }
        | WHILE bool_exp BEGINLOOP statements ENDLOOP 
        {
                std::string temp;
                std::string begin = new_label();
                std::string inner = new_label();
                std::string after = new_label();
                std::string code = $4.code;
                size_t pos = code.find("continue");
                while (pos != std::string::npos){
                        code.replace(pos, 8, ":="+begin);
                        pos = code.find("continue");
                }     
                temp.append(": ");
                temp += begin + "\n";
                temp.append($2.code);
                temp += "?:= " + inner +", ";
                temp.append($2.place);
                temp.append("\n");
                temp +=":= "+ after + "\n";
                temp += ": "+ inner + "\n";
                temp.append(code);
                temp +=":= " + begin + "\n";
                temp +=":= " + after + "\n";
                $$.code = strdup(temp.c_str());
        }
        | DO BEGINLOOP statements ENDLOOP WHILE bool_exp 
        {
               std::string temp;
               std::string begin = new_label();
               std::string condition = new_label();
               std::string code = $3.code;
               size_t pos = code.find("continue");
               while(pos != std::string::npos){
                       code.replace(pos, 8, ":= " + condition);
                       pos = code.find("continue");
               } 
               temp.append(": ");
               temp += begin + "\n";
               temp.append(code);
               temp += ": " + condition + "\n";
               temp.append($6.code);
               temp += "?:= " +begin + ", ";
               temp.append($6.place);
               temp.append("\n");
               $$.code = strdup(temp.c_str());
        }
        | READ vars 
        {
              std::string temp;
              temp.append($2.code);
              size_t pos = temp.find("|", 0);
              while(pos != std::string::npos){
                      temp.replace(pos, 1, "<");
                      pos = temp.find("|", pos);
              }  
              $$.code = strdup(temp.c_str());
        }
        | WRITE vars 
        {
              std::string temp;
              temp.append($2.code);
              size_t pos = temp.find("|", 0);
              while(pos != std::string::npos){
                      temp.replace(pos, 1, ">");
                      pos = temp.find("|", pos);
              }  
              $$.code = strdup(temp.c_str());  
        }
        | CONTINUE 
        {
                $$.code = strdup("continue\n");
        }
        |RETURN expression 
        {
                std::string temp;
                temp.append($2.code);
                temp.append("ret ");
                temp.append($2.place);
                temp.append("\n");
                $$.code = strdup(temp.c_str());
        }
        ;

vars:       var 
        {
                std::string temp;
                temp.append($1.code);
                if($1.arr){
                        temp.append(".[]| ");
                } else {
                        temp.append(".| ");
                }
                temp.append($1.place);
                temp.append("\n");
                $$.code = strdup(temp.c_str());
                $$.place = strdup("");
        }
        | var COMMA vars 
        {
                std::string temp;
                temp.append($1.code);
                if($1.arr){
                        temp.append(".[]| ");
                } else {
                        temp.append(".| ");
                }
                temp.append($1.place);
                temp.append("\n");
                temp.append($3.code);
                $$.code = strdup(temp.c_str());
                $$.place = strdup("");
        }
        ;

bool_exp:  relation_and_expr 
        {
                $$.code = strdup($1.code);
                $$.place = strdup($1.place);
        }
        |relation_and_expr OR bool_exp 
        {
                std::string temp;
                std::string dst = new_temp();
                temp.append($1.code);
                temp.append($3.code);
                temp += ". "+dst + "\n";
                temp +="|| "+dst+", ";
                temp.append($1.place);
                temp.append(", ");
                temp.append($3.place);
                temp.append("\n");
                $$.code = strdup(temp.c_str());
                $$.place = strdup(dst.c_str());
        }
        ;

relation_and_expr: relation_expr 
        {
                $$.code = strdup($1.code);
                $$.place = strdup($1.place);
        }
        |relation_expr AND relation_and_expr
        {
                std::string temp;
                std::string dst = new_temp();
                temp.append($1.code);
                temp.append($3.code);
                temp+=". " +dst +"\n";
                temp += "&& "+ dst + ", ";
                temp.append($1.place);
                temp.append(", ");
                temp.append($3.place);
                temp.append("\n");
                $$.code = strdup(temp.c_str());
                $$.place = strdup(dst.c_str());
        }
        ;

relation_expr:     expression comp expression 
        {
                std::string dst = new_temp();
                std::string temp;
                temp.append($1.code);
                temp.append($3.code);
                temp = temp + ". " + dst + "\n" + $2.place + dst + ", " + $1.place + ", " + $3.place + "\n";
                $$.code = strdup(temp.c_str());
                $$.place = strdup(dst.c_str());


        }
        | NOT expression comp expression 
        {
                std::string dst = new_temp();
                std::string temp;
                temp.append("! ");
                temp.append($2.code);
                temp.append($4.code);
                temp = temp + ". " + dst + "\n" + $3.place + dst + ", " + $2.place + ", " + $4.place + "\n";
                $$.code = strdup(temp.c_str());
                $$.place = strdup(dst.c_str());

        }
        | TRUE 
        {
                std::string temp;
                temp.append("1");
                $$.code = strdup("");
                $$.place = strdup(temp.c_str());
        }
        | NOT TRUE 
        {
                std::string temp;
                temp.append("! 1");
                $$.code = strdup("");
                $$.place = strdup(temp.c_str());
        }
        | FALSE 
        {
                std::string temp;
                temp.append("0");
                $$.code = strdup("");
                $$.place = strdup(temp.c_str());
        }
        | NOT FALSE 
        {
                std::string temp;
                temp.append("! 0");
                $$.code = strdup("");
                $$.place = strdup(temp.c_str());
        }
        | L_PAREN bool_exp R_PAREN 
        {
                $$.code = strdup($2.code);
                $$.place = strdup($2.place);
        }
        | NOT L_PAREN bool_exp R_PAREN 
        {
                std::string temp ; 
                temp.append("! ");
                temp.append($3.code);
                $$.code = strdup(temp.c_str());
                $$.place = strdup($3.place);
        }
        ;

comp:   EQ 
        {
                std::string temp = "== ";
                $$.place = strdup(temp.c_str());
                $$.code = strdup("");
        }
        | NEQ 
        {
                std::string temp = "!= ";
                $$.place = strdup(temp.c_str());
                $$.code = strdup("");
        }
        | LT 
        {
                std::string temp = "< ";
                $$.place = strdup(temp.c_str());
                $$.code = strdup("");
        }
        | GT 
        {
                std::string temp = "> ";
                $$.place = strdup(temp.c_str());
                $$.code = strdup("");
        }
        | LTE 
        {
                std::string temp = "<= ";
                $$.place = strdup(temp.c_str());
                $$.code = strdup("");
        }
        | GTE 
        {
                std::string temp = ">= ";
                $$.place = strdup(temp.c_str());
                $$.code = strdup("");
        }
        ;

expressions:    expression 
        {
                std::string temp;
                temp.append($1.code);
                temp.append("param ");
                temp.append($1.place);
                temp.append("\n");
                $$.place = strdup("");
                $$.code = strdup(temp.c_str());
        }
        | expression COMMA expressions 
        {
                std::string temp;
                temp.append($1.code);
                temp.append("param ");
                temp.append($1.place);
                temp.append("\n");
                temp.append($3.code);
                $$.place = strdup("");
                $$.code = strdup(temp.c_str());
        }
        ;

expression:  multiplicative_expr 
        {
                $$.code = strdup($1.code);
                $$.place = strdup($1.place);
        }
        | multiplicative_expr ADD expression 
        {
                std::string temp;
                std::string dst = new_temp();
                temp.append($1.code);
                temp.append($3.code);
                temp += ". " +dst + "\n";
                temp += "+ " +dst + ", ";
                temp.append($1.place);
                temp += ", ";
                temp.append($3.place);
                temp += "\n";
                $$.code = strdup(temp.c_str());
                $$.place = strdup(dst.c_str());
        }
        | multiplicative_expr SUB expression 
        {
                std::string temp;
                std::string dst = new_temp();
                temp.append($1.code);
                temp.append($3.code);
                temp += ". " +dst + "\n";
                temp += "- " +dst + ", ";
                temp.append($1.place);
                temp += ", ";
                temp.append($3.place);
                temp += "\n";
                $$.code = strdup(temp.c_str());
                $$.place = strdup(dst.c_str());
        }
        ;

multiplicative_expr:  term 
        {
                $$.code = strdup($1.code);
                $$.place = strdup($1.place);
        }
        | term MOD multiplicative_expr 
        {
                std::string temp;
                std::string dst = new_temp();
                temp.append($1.code);
                temp.append($3.code);
                temp.append(". ");
                temp.append(dst);
                temp.append("\n");
                temp += "% " +dst +", ";
                temp.append($1.place);
                temp += ", ";
                temp.append($3.place);
                temp +="\n";
                $$.code = strdup(temp.c_str());
                $$.place = strdup(dst.c_str());
        }
        | term MULT multiplicative_expr 
        {
                std::string temp;
                std::string dst = new_temp();
                temp.append($1.code);
                temp.append($3.code);
                temp.append(". ");
                temp.append(dst);
                temp.append("\n");
                temp += "* " +dst +", ";
                temp.append($1.place);
                temp += ", ";
                temp.append($3.place);
                temp +="\n";
                $$.code = strdup(temp.c_str());
                $$.place = strdup(dst.c_str());
        }
        | term DIV multiplicative_expr 
        {
                std::string temp;
                std::string dst = new_temp();
                temp.append($1.code);
                temp.append($3.code);
                temp.append(". ");
                temp.append(dst);
                temp.append("\n");
                temp += "/ " +dst +", ";
                temp.append($1.place);
                temp += ", ";
                temp.append($3.place);
                temp +="\n";
                $$.code = strdup(temp.c_str());
                $$.place = strdup(dst.c_str());
        }
        ;


term:	var
        {
                std::string dst = new_temp();
                std::string temp;
                if($1.arr) {
                        temp.append($1.code);
                        temp.append(". ");
                        temp.append(dst);
                        temp.append("\n");
                        temp += "=[] " + dst + ", ";
                        temp.append($1.place);
                        temp.append("\n");
                } else {
                        temp.append(". ");
                        temp.append(dst);
                        temp.append("\n");
                        temp = temp + "= " + dst +", ";
                        temp.append($1.place);
                        temp.append("\n");
                        temp.append($1.code);
                }
                if(varTemp.find($1.place) != varTemp.end()) {
                        varTemp[$1.place] = dst;
                }
                $$.code = strdup(temp.c_str());
                $$.place = strdup(dst.c_str());
        }
	| SUB var 
        {
                std::string dst = new_temp();
                std::string temp;
                if($2.arr){
                        temp.append($2.code);
                        temp.append(". ");
                        temp.append(dst);
                        temp.append("\n");
                        temp += "=[] " +dst + ", ";
                        temp.append($2.place);
                        temp.append("\n");
                } else {
                        temp.append(". ");
                        temp.append(dst);
                        temp.append("\n");
                        temp = temp + "= " + dst + ", ";
                        temp.append($2.place);
                        temp.append("\n");
                        temp.append($2.code);
                }
                if (varTemp.find($2.place) != varTemp.end()) {
                        varTemp[$2.place] = dst;
                }
                temp += "* " +dst + ", " + dst + ", -1\n";
                $$.code = strdup(temp.c_str());
                $$.place = strdup(dst.c_str());
        }
	| NUMBER 
        {
                std::string dst = new_temp();
                std::string temp;
                temp.append(". ");
                temp.append(dst);
                temp.append("\n");
                temp = temp + "= " +dst + ", " + std::to_string($1) + "\n";
                $$.code = strdup(temp.c_str());
                $$.place = strdup(dst.c_str());
        }
	| SUB NUMBER 
        {
                std::string dst = new_temp();
                std::string temp;
                temp.append(". ");
                temp.append(dst);
                temp.append("\n");
                temp = temp + "= " +dst + ", -"+ std::to_string($2) + "\n";
                $$.code = strdup(temp.c_str());
                $$.place = strdup(dst.c_str());
        }
	| L_PAREN expression R_PAREN 
        {
                $$.code = strdup($2.code);
                $$.place = strdup($2.place);
        }
	| SUB L_PAREN expression R_PAREN 
        {
                std::string temp;
                temp.append($3.code);
                temp.append("* ");
                temp.append($3.place);
                temp.append(", ");
                temp.append($3.place);
                temp.append(", -1\n");
                $$.code = strdup(temp.c_str());
                $$.place = strdup($3.place);
        }
	| identifier L_PAREN R_PAREN 
        {

        }
	| identifier L_PAREN expressions R_PAREN 
        {
                std::string temp;
                std::string func = $1.place;
                if(funcs.find(func) == funcs.end()) {
                        printf("Calling undeclared function %s. \n", func.c_str());
                }
                std::string dst = new_temp();
                temp.append($3.code);
                temp += ". " + dst + "\ncall ";
                temp.append($1.place);
                temp += ", " + dst + "\n";
                $$.code = strdup(temp.c_str());
                $$.place = strdup(dst.c_str());
        }
	;

var:       identifier
        {
                std::string temp;
                $$.code = strdup("");
                std::string ident = $1.place;
                if(funcs.find(ident) == funcs.end() && varTemp.find(ident)== varTemp.end()){
                        printf("Idnetifier %s is not declared.\n", ident.c_str());
                } else if(arrSize[ident]>1){
                        printf("Did not provide index for array Identifier %s.\n", ident.c_str());
                }
                $$.place = strdup(ident.c_str());
                $$.arr = false;
        }
        | identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET 
        {
                std::string temp;
                std::string ident = $1.place;
                 if(funcs.find(ident) == funcs.end() && varTemp.find(ident)== varTemp.end()){
                        printf("Idnetifier %s is not declared.\n", ident.c_str());
                } else if(arrSize[ident] == 1){
                        printf("Provide index for non-array Identifier %s.\n", ident.c_str());
                }
                temp.append($1.place);
                temp.append(", ");
                temp.append($3.place);
                $$.code = strdup($3.code);
                $$.place = strdup(temp.c_str());
                $$.arr = true;
        }
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

std::string new_temp(){
        std::string t = "t" + std::to_string(tempCount);
        tempCount++;
        return t;
}

std::string new_label(){
        std::string l = "l" + std::to_string(labelCount);
        labelCount++;
        return l;
}