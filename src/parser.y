%{
#include <stdio.h>
#include <stdlib.h>
#include "symbolTable.c"
struct TreeNode
{
    char* val;
    char* type;
	int length;
    struct TreeNode ** child;
};
struct TreeNode * ROOT;
int i=1,lnum1=0, count = 0;
int stack[100],index1=0,end[100],arr[10],ct,c,b,fl,top=0,label[20],label_num=0,ltop=0;

int plist[100],k=-1,errc=0,j=0;
extern int yylineno;

//中间代码输出控件
char st1[100][10];
int tmp_cnt = 0;
char temp[2]="t";
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
//一开始想用itoa()函数将数字转换为字符串
//但发现Unix环境下没有itoa()
//于是自己实现了一个itoa()
char* itoa_unix(int num)
{
	char *str = (char *)malloc(sizeof(char)*10);
	sprintf(str, "%d", num);
	// printf("The itoa res is:%s", str);
	return str;
}
int getType(char * s)
{
	int type = 0;
	if(!(strcmp(s, "INT")))
	{
		type = 258;
	}
	if(!(strcmp(s, "FLOAT")))
	{
		type = 259;
	}
	if(!(strcmp(s, "VOID")))
	{
		type = 260;
	}
	return type;
}

%}
%union {
	int ival;
	char *str;
	struct TreeNode* node;
}
%token<ival> INT FLOAT VOID
%token<str> ID NUM REAL STRING
%token WHILE IF RETURN PREPROC LE PRINT FUNCTION ARRAY ELSE BREAK STRUCT_VAR FOR GE EQ NE INC DEC AND OR
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
	int type = getType($1->val);
	if(strcmp($2,"main")!=0)
	{
		printf("goto F%d\n",lnum1);
	}
	if (getType($1->val)!=returntype_func(ct))
	{
		printf("\nError : Type mismatch : Line %d\n",yylineno); errc++;
	}
	insert($2,FUNCTION);
	insert($2,getType($1->val));
	for(j=0;j<=k;j++)//插入参数
	{
		insert_parameter($2,plist[j]);
	}
	k=-1;
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
	plist[++k]=getType($1->val);
	int type = getType($1->val);
	insert($2,type);
	insertscope($2,i);
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
 	| BREAK {
		struct TreeNode* child[1];
		child[0] = createTreeNode("BREAK", NULL, NULL, 0);
		$$ = createTreeNode("stmt", NULL, child, 1);
}
	| RETURN consttype SEMI {
		struct TreeNode* child[2];
		child[0] = createTreeNode("RETURN", NULL, NULL, 0);
		child[1] = $2;
		$$ = createTreeNode("stmt", NULL, child, 2);
		if(!(strspn($2->val,"0123456789")==strlen($2->val)))
			storereturn(ct,FLOAT);
		else
			storereturn(ct,INT); 
		ct++;
}
	| RETURN SEMI {
		struct TreeNode* child[1];
		child[0] = createTreeNode("RETURN", NULL, NULL, 0);
		$$ = createTreeNode("stmt", NULL, child, 1);
		storereturn(ct,VOID); 
		ct++;
}
	| RETURN ID SEMI {
		struct TreeNode* child[2];
		child[0] = createTreeNode("RETURN", NULL, NULL, 0);
		child[1] = createTreeNode("ID", $2, NULL, 0);
		$$ = createTreeNode("stmt", NULL, child, 2);
		int sct=returnscope($2,stack[top-1]);	//stack[top-1] - current scope
		int type=returntype($2,sct);
		if (type==259) storereturn(ct,FLOAT);
		else storereturn(ct,INT);
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
	| {
	$$ = createTreeNode("else", NULL, NULL, 0);
	label_num--;
	ltop--;
}
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
		int sct=returnscope($1,stack[index1-1]);
		int type=returntype($1,sct);
		if((!(strspn($5->val,"0123456789")==strlen($5->val))) && type==258 && fl==0)
			printf("\nError : Type Mismatch : Line %d\n",yylineno);
		if(!lookup($1))
		{
			int currscope=stack[index1-1];
			int scope=returnscope($1,currscope);
			if((scope<=currscope && end[scope]==0) && !(scope==0))
			{
				check_scope_update($1,$5->val,currscope);
			}
		}
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
		if( (!(strspn($6->val,"0123456789")==strlen($6->val))) && getType($1->val)==258 && (fl==0))
		{
			printf("\nError : Type Mismatch : Line %d\n",yylineno);
			fl=1;
		}
		if(!lookup($2))
		{
			int currscope=stack[index1-1];
			int previous_scope=returnscope($2,currscope);
			if(currscope==previous_scope)
				printf("\nError : Redeclaration of %s : Line %d\n",$2,yylineno);
			else
			{
				insert_dup($2,getType($1->val),currscope);
				check_scope_update($2,$6->val,stack[index1-1]);
				int sg=returnscope($2,stack[index1-1]);
			}
		}
		else
		{
			int scope=stack[index1-1];
			insert($2,getType($1->val));
			insertscope($2,scope);
			check_scope_update($2,$6->val,stack[index1-1]);
		}
	}

	| assignment1 SEMI  {
		struct TreeNode* child[1] = {$1};
		$$ = createTreeNode("declaration", NULL, child, 1);
		if(!lookup($1->val))
		{
			int currscope=stack[index1-1];
			int scope=returnscope($1->val,currscope);
			if(!(scope<=currscope && end[scope]==0) || scope==0)
				printf("\nError : Variable %s out of scope : Line %d\n",$1->val,yylineno);
		}
		else
			printf("\nError : Undeclared Variable %s : Line %d\n",$1->val,yylineno);
		}

		| Type ID LBK index RBK SEMI {
			struct TreeNode* child[5];
			child[0] = $1;
			child[1] = createTreeNode("ID", $2, NULL, 0);
			child[2] = createTreeNode("\"[\"", NULL, NULL, 0);
			child[3] = $4;
			child[4] = createTreeNode("\"]\"", NULL, NULL, 0);
			$$ = createTreeNode("declaration", NULL, child, 5);
			int itype;
			if(!(strspn($4->val,"0123456789")==strlen($4->val))) 
				itype=259;
			else itype = 258;
			if(itype!=258)
			{ 
				printf("\nError : Array index must be of type int : Line %d\n",yylineno);
			  	errc++;
			}
			if(atoi($4->val)<=0)
			{ printf("\nError : Array index must be of type int > 0 : Line %d\n",yylineno);errc++;}
			if(!lookup($2))
			{
				int currscope=stack[top-1];
				int previous_scope=returnscope($2,currscope);
				if(currscope==previous_scope)
				{printf("\nError : Redeclaration of %s : Line %d\n",$2,yylineno);errc++;}
				else
				{
					insert_dup($2,ARRAY,currscope);
					insert_by_scope($2,getType($1->val),currscope);	//to insert type to the correct identifier in case of multiple entries of the identifier by using scope
					if (itype==258) {insert_index($2,$4->val);}
				}
			}
			else
			{
				int scope=stack[top-1];
				insert($2,ARRAY);
				insert($2,getType($1->val));
				insertscope($2,scope);
				if (itype==258) {insert_index($2,$4->val);}
			}
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
