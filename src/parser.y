%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
struct TreeNode
{
    char* val;
    char* type;
	int length;
    struct TreeNode ** child;
};
struct TreeNode * ROOT;

extern int yylineno;

void yyerror(char *s);

struct TreeNode * createTreeNode(char * type, char * val, struct TreeNode ** child, int length)
{
	struct TreeNode * node = (struct TreeNode *)malloc(sizeof(struct TreeNode));
	struct TreeNode **temp = (struct TreeNode **)malloc(sizeof(struct TreeNode *)*length);
	node->val = val;
	node->type = type;
	for(int i = 0; i < length; i++)
	{
		temp[i] = child[i];
	}
	node->child = temp;
	node->length = length;
	return node;
}
char * getString(struct TreeNode* root){
	if((!strcmp(root->type, "ID"))||(!strcmp(root->type, "Type"))||(!strcmp(root->type, "consttype"))){
		return root->val;
	}
	else{
		return root->type;
	}
}

%}
%union {
	int ival;
	char *str;
	struct TreeNode* node;
}
%token<ival> INT FLOAT VOID
%token<str> ID NUM REAL STRING
%token WHILE IF RETURN PREPROC LE PRINT FUNCTION DO ARRAY ELSE STRUCT STRUCT_VAR FOR GE EQ NE INC DEC AND OR
%token LBR RBR LBK RBK LP RP COMMA SEMI MOD
%left LE GE EQ NEQ AND OR LABK RABK
%right VAL
%right UMINUS
%left PLUS MINUS MUL DIV
%start program
%type<node> start Function Declaration parameter_list parameter StmtList stmt index assignment1 consttype E T F
%type<node> if while for Type else array
%%

program : start{
	if($1->length != 0)
	{
		printf("TYPE: %s\n", $1->type);
		if($1->val!=NULL)
		printf("VAL: %s\n", $1->val);
		if($1->child!=NULL)
		printf("CHILD: %s\n", $1->child);
		printf("LENGTH: %d\n", $1->length);
		ROOT = $1;
		printf("PARSE END");
	}
}

start : Function start {
		struct TreeNode * child[2] = {$1, $2};
		$$ = createTreeNode("start", NULL, child, 2);
}
	| PREPROC start {
		struct TreeNode * child[2];
		struct TreeNode * temp = createTreeNode("PREPROC", NULL, NULL, 0);
		child[0] = temp;
		child[1] = $2;
		$$ = createTreeNode("start", NULL, child, 2); 
	}
	| Declaration start {
		struct TreeNode * child[2] = {$1, $2};
		$$ = createTreeNode("start", NULL, child, 2);
	}
	| {
		$$ = createTreeNode("start", NULL, NULL, 0);
	}
	;

Function : Type ID LP parameter_list RP LBR StmtList RBR  {
	struct TreeNode * child[4];
	child[0] = $1;
	child[1] = createTreeNode("ID", $2, NULL, 0);
	child[2] = $4;
	child[3] = $7;
	$$ = createTreeNode("Function", NULL, child, 4);
}
	;

parameter_list : parameter_list COMMA parameter {
	struct TreeNode * child[2] = {$1, $3};
	$$ = createTreeNode("parameter_list", NULL, child, 2);
}
	            | parameter {
		struct TreeNode * child[1] = {$1};
		$$ = createTreeNode("parameter_list", NULL, child, 1);
}
	            | {$$ = createTreeNode("parameter_list", NULL, NULL, 0);};

parameter : Type ID {
	struct TreeNode * child[2];
	child[0] = $1;
	child[1] = createTreeNode("ID", $2, NULL, 0);
	$$ = createTreeNode("parameter", $2, child, 2);
}
	        ;

Type : INT {$$ = createTreeNode("Type", "INT", NULL, 0);}
	| FLOAT{$$ = createTreeNode("Type", "FLOAT", NULL, 0);}
	| VOID {$$ = createTreeNode("Type", "VOID", NULL, 0);}
	;

StmtList : StmtList stmt{
	struct TreeNode * child[2] = {$1, $2};
	$$ = createTreeNode("StmtList", NULL, child, 2);
}
	| {$$ = createTreeNode("StmtList", NULL, NULL, 0);}
	;

stmt : Declaration {struct TreeNode* child[1] = {$1}; $$ = createTreeNode("stmt", NULL, child, 1);}
	| if {struct TreeNode* child[1] = {$1}; $$ = createTreeNode("if", NULL, child, 1);}
	| while {struct TreeNode* child[1] = {$1}; $$ = createTreeNode("while", NULL, child, 1);}
	| for {struct TreeNode* child[1] = {$1}; $$ = createTreeNode("for", NULL, child, 1);}
	| RETURN consttype SEMI {
		struct TreeNode* child[2];
		child[0] = createTreeNode("RETURN", NULL, NULL, 0);
		child[1] = $2;
		$$ = createTreeNode("stmt", NULL, child, 2);
}
	| RETURN SEMI {
		struct TreeNode* child[1];
		child[0] = createTreeNode("RETURN", NULL, NULL, 0);
		$$ = createTreeNode("stmt", NULL, child, 1);
}
	| RETURN ID SEMI {
		struct TreeNode* child[2];
		child[0] = createTreeNode("RETURN", NULL, NULL, 0);
		child[1] = createTreeNode("ID", $2, NULL, 0);
		$$ = createTreeNode("stmt", NULL, child, 2);
		ct++;
}
	| SEMI {
		struct TreeNode* child[1];
		child[0] = createTreeNode("SEMI", NULL, NULL, 0);
		$$ = createTreeNode("stmt", NULL, child, 1);
}
	| PRINT LP STRING RP SEMI {
		struct TreeNode* child[2];
		child[0] = createTreeNode("PRINT", NULL, NULL, 0);
		child[1] = createTreeNode("STRING", $3, NULL, 0);
		$$ = createTreeNode("stmt", NULL, child, 2);
}
	| PRINT LP ID RP SEMI {
		struct TreeNode* child[2];
		child[0] = createTreeNode("PRINT", NULL, NULL, 0);
		child[1] = createTreeNode("ID", $3, NULL, 0);
		$$ = createTreeNode("stmt", NULL, child, 2);
}
	| LBR StmtList RBR {
		struct TreeNode* child[1] = {$2};
		$$ = createTreeNode("stmt", NULL, child, 1);
}
	;


for	: FOR LP E  SEMI E SEMI E RP LBR StmtList RBR 
{
	struct TreeNode* child[5];
	child[0] = createTreeNode("FOR", NULL, NULL, 0);
	child[1] = $3;
	child[2] = $6;
	child[3] = $9;
	child[4] = $13;
	$$ = createTreeNode("for", NULL, child, 5);
}
	;

if : 	 IF LP E RP LBR StmtList RBR else {
	struct TreeNode* child[4];
	child[0] = createTreeNode("IF", NULL, NULL, 0);
	child[1] = $3;
	child[2] = $7; 
	child[3] = $10;
	$$ = createTreeNode("if", NULL, child, 4);
}
	;

else : ELSE LBR StmtList RBR {
	struct TreeNode* child[2];
	child[0] = createTreeNode("ELSE", NULL, NULL, 0);
	child[1] = $3;
	$$ = createTreeNode("else", NULL, child, 2);
}
	| {$$ = createTreeNode("else", NULL, NULL, 0);}
	;

while : WHILE LP E RP  LBR StmtList RBR {
	struct TreeNode* child[3];
	child[0] = createTreeNode("WHILE", NULL, NULL, 0);
	child[1] = $4;
	child[2] = $8;
	$$ = createTreeNode("while", NULL, child, 3);
}
	;

index : ID {
	if(lookup($1))
	printf("\nUndeclared Variable %s : Line %d\n",$1,yylineno);
	struct TreeNode* child[1];
	child[0] = createTreeNode("ID", NULL, NULL, 0);
	$$ = createTreeNode("index", $1, child, 1);
}
	| consttype{
	struct TreeNode* child[1] = {$1};
	$$ = createTreeNode("index", $1->val, child, 1);
}
	;


assignment1 : ID VAL  E 
	{
		struct TreeNode* child[3];
		child[0] = createTreeNode("ID", $1, NULL, 0);
		child[1] = createTreeNode("VAL", "\"=\"", NULL, 0);
		child[2] = $5;
		$$ = createTreeNode("assignment", $1, child, 3);
	}
	;



consttype : NUM {$$ = createTreeNode("consttype", $1, NULL, 0);}
	| REAL {$$ = createTreeNode("consttype", $1, NULL, 0);}
	;

Declaration : Type ID  VAL E  SEMI
	{
		int type = 0;
		struct TreeNode* child[4];
		child[0] = $1;
		child[1] = createTreeNode("ID", $2, NULL, 0);
		child[2] = createTreeNode("\"=\"", NULL, NULL, 0);
		child[3] = $6;
		$$ = createTreeNode("Declaration", NULL, child, 4);
	}

	| assignment1 SEMI  {
		struct TreeNode* child[1] = {$1};
		$$ = createTreeNode("declaration", NULL, child, 1);
		}

		| Type ID LBK index RBK SEMI {
			struct TreeNode* child[5];
			child[0] = $1;
			child[1] = createTreeNode("ID", $2, NULL, 0);
			child[2] = createTreeNode("\"[\"", NULL, NULL, 0);
			child[3] = $4;
			child[4] = createTreeNode("\"]\"", NULL, NULL, 0);
			$$ = createTreeNode("declaration", NULL, child, 5);
		}
	| error {}
	;

array : ID LBK E RBK{
	struct TreeNode* child[2];
	child[0] = createTreeNode("ID", $1, NULL, 0);
	child[1] = $4;
	$$ = createTreeNode("Array", $1, child, 2);
}
	;

E :  E PLUS T
{
	struct TreeNode* child[3];
	char * temp = (char *)malloc(strlen($1->val)*sizeof(char));
	strcpy(temp, $1->val);
	strcat(temp, $4->val);
	child[0] = $1;
	child[1] = createTreeNode("\"+\"", NULL, NULL, 0);
	child[2] = $4;
	$$ = createTreeNode("E", temp, child, 3);
}
   | E MINUS T
{
	struct TreeNode* child[3];
	char * temp = (char *)malloc(strlen($1->val)*sizeof(char));
	strcpy(temp, $1->val);
	strcat(temp, $4->val);
	child[0] = $1;
	child[1] = createTreeNode("\"-\"", NULL, NULL, 0);
	child[2] = $4;
	$$ = createTreeNode("E", temp, child, 3);
}
   | T
{
	struct TreeNode* child[1] = {$1};
	$$ = createTreeNode("E", $1->val, child, 1);
}
   | ID  LE  E {
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1, NULL, 0);
	child[1] = createTreeNode("\"<=\"", NULL, NULL, 0);
	child[2] = $3;
	$$ = createTreeNode("E", $3->val, child, 3);
}
   | ID  GE  E {
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1, NULL, 0);
	child[1] = createTreeNode("\">=\"", NULL, NULL, 0);
	child[2] = $3;
	$$ = createTreeNode("E", $3->val, child, 3);
}
   | ID  EQ  E {
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $3, NULL, 0);
	child[1] = createTreeNode("\"==\"", NULL, NULL, 0);
	child[2] = $3;
	$$ = createTreeNode("E", $3->val, child, 3);
}
   | ID  NEQ  E {
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1, NULL, 0);
	child[1] = createTreeNode("\"!=\"", NULL, NULL, 0);
	child[2] = $3;
	$$ = createTreeNode("E", $3->val, child, 3);
}
   | ID  AND  E {
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1, NULL, 0);
	child[1] = createTreeNode("\"&&\"", NULL, NULL, 0);
	child[2] = $3;
	$$ = createTreeNode("E", $3->val, child, 3);
}
   | ID  OR  E {
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1, NULL, 0);
	child[1] = createTreeNode("\"||\"", NULL, NULL, 0);
	child[2] = $3;
	$$ = createTreeNode("E", $3->val, child, 3);
}
   | ID  LABK   E {
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1, NULL, 0);
	child[1] = createTreeNode("\"<\"", NULL, NULL, 0);
	child[2] = $3;
	$$ = createTreeNode("E", $3->val, child, 3);
}
   | ID  RABK  E {
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1, NULL, 0);
	child[1] = createTreeNode("\">\"", NULL, NULL, 0);
	child[2] = $3;
	$$ = createTreeNode("E", NULL, child, 3);
}
   | ID  VAL   E {
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1, NULL, 0);
	child[1] = createTreeNode("\"=\"", NULL, NULL, 0);
	child[2] = $5;
	$$ = createTreeNode("E", $3->val, child, 3);
}
   | array {
	array1();
	struct TreeNode* child[1] = {$1};
	$$ = createTreeNode("E", $1->val, child, 1);
}
   ;
T :  T MUL F
{
	struct TreeNode* child[3];
	char * temp = (char *)malloc(strlen($1->val)*sizeof(char));
	strcpy(temp, $1->val);
	strcat(temp, $3->val);
	child[0] = $1;
	child[1] = createTreeNode("\"*\"", NULL, NULL, 0);
	child[2] = $3;
	$$ = createTreeNode("T", temp, child, 3);
}
   | T DIV F
{
	struct TreeNode* child[3];
	char * temp = (char *)malloc(strlen($1->val)*sizeof(char));
	strcpy(temp, $1->val);
	strcat(temp, $3->val);
	child[0] = $1;
	child[1] = createTreeNode("\"/\"", NULL, NULL, 0);
	child[2] = $3;
	$$ = createTreeNode("T", temp, child, 3);
}
   | F
{
	struct TreeNode* child[1] = {$1};
	$$ = createTreeNode("T", $1->val, child, 1);
}
   ;
F :  LP E RP {
	struct TreeNode* child[3];
	child[0] = createTreeNode("\"(\"", NULL, NULL, 0);
	child[1] = $2;
	child[2] = createTreeNode("\")\"", NULL, NULL, 0);
	$$=createTreeNode("F", $2->val, child, 3);
}
   | MINUS F %prec UMINUS{
	   struct TreeNode* child[2];
	   child[0] = createTreeNode("\"-\"", NULL, NULL, 0);
	   child[1] = $2;
	   $$=createTreeNode("F", $2->val, child, 2);
   }
   | ID {
	   struct TreeNode* child[1];
	   child[0] = createTreeNode("ID", $1, NULL, 0);
	   $$=createTreeNode("F", $1, child, 1);
	   fl=1;
}
   | consttype {
	   struct TreeNode* child[1] = {$1};
	   $$=createTreeNode("F", $1->val, child, 1);
}
   ;

%%

#include "lex.yy.c"
#include<ctype.h>

int yywrap()
{
	return 1;
}
int main(int argc, char *argv[])
{
	yyin =fopen(argv[1],"r");
	yyparse();
	if(!yyparse())
	{
		printf("\nParsing Done With %d Error\n", errc);
	}
	else
	{
		printf("Error\n");
	}
	fclose(yyin);
	return 0;
}

void yyerror(char *s)
{
	printf("\nLine %d : %s %s\n",yylineno,s,yytext);
}
