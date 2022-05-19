%{
#include <stdio.h>
#include <stdlib.h>
#include "symbolTable.c"
struct TreeNode
{
    char* val;
    char* type;
	int length;
	int num;
	int isFunc;
    struct TreeNode ** child;
};
struct TreeNode * ROOT;
int i=1,lnum1=0, count = 0, fnum = 0;
int stack[100],index1=0,end[100],arr[10],ct,c,b,fl,top=0,label[20],label_num=0,ltop=0;
static char percent[50] = "%";
int paraTypeList[100], k=-1, errc=0, j=0;
extern int yylineno;
extern FILE* yyout;
//中间代码输出控件
char st1[100][10];
int tmp_cnt = 0, para_cnt = 0;
int breakFlag = 0;
char temp[2]="t";
void yyerror(char *s);
int yylex();
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
	if (root == NULL || root->type == NULL)
	{
		char * nullString = (char *)malloc(sizeof(char)*5);
		strcpy(nullString, "NULL");
		return nullString;
	}
	if((!strcmp(root->type, "ID"))||(!strcmp(root->type, "Type"))||(!strcmp(root->type, "consttype"))||(!strcmp(root->type, "NUM"))||(!strcmp(root->type, "STRING"))){
		char * temp = (char *)malloc(sizeof(char) * (strlen(root->val)+1));
		strcpy(temp,root->val);
		return temp;
	}
	else{
		return root->type;
	}
}
void traverseTree(FILE* fp, struct TreeNode* root, int num)
{
	int i = 0;
	if(root == NULL || root->length == 0) //The root is a leave node
	{
		return;
	}
	else
	{
		for(i = 0;i<root->length;i++)
		{
			count++;
			fprintf(fp, "node%d[label = %s]\n", count, getString(root->child[i]));
			fprintf(fp, "node%d -> node%d\n", num, count);
			traverseTree(fp, root->child[i], count);
		}
	}
	return;
}
//一开始想用itoa()函数将数字转换为字符串
//但发现Unix环境下没有itoa()
//于是自己实现了一个itoa()
char* itoa_unix(int num)
{
	char *str = (char *)malloc(sizeof(char)*10);
	sprintf(str, "%d", num);
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

void scope_start()
{
	stack[index1]=i;
	i++;
	index1++;
	return;
}
void scope_end()
{
	index1--;
	end[stack[index1]]=1;
	stack[index1]=0;
	return;
}
void if1()
{
	label_num++;
	strcpy(temp,"t");
	char * res = itoa_unix(tmp_cnt);
	strcat(temp, res);
	fprintf(yyout, "%s = not %s\n",temp,st1[top]);
 	fprintf(yyout, "if %s goto L%d\n",temp,label_num);
	tmp_cnt++;
	label[++ltop]=label_num;
}
void if2()
{
	label_num++;
	fprintf(yyout, "goto L%d\n",label_num);
	fprintf(yyout, "L%d: \n",label[ltop--]);
	label[++ltop]=label_num;
}
void if3()
{
	fprintf(yyout, "L%d:\n",label[ltop--]);
}
void while1()
{
	label_num++;
	label[++ltop]=label_num;
	fprintf(yyout, "L%d:\n",label_num);
}
void while2()
{
	label_num++;
	strcpy(temp,"t");
	strcat(temp,itoa_unix(tmp_cnt));
	fprintf(yyout, "%s = not %s\n",temp,st1[top--]);
 	fprintf(yyout, "if %s goto L%d\n",temp,label_num);
	tmp_cnt++;
	label[++ltop]=label_num;
	breakFlag = label_num;
}
void while3()
{
	int y=label[ltop--];
	fprintf(yyout, "goto L%d\n",label[ltop--]);
	fprintf(yyout, "L%d:\n",y);
}
void for1()
{
	label_num++;
	label[++ltop]=label_num;
	fprintf(yyout, "L%d:\n",label_num);
}
void for2()
{
	label_num++;
	strcpy(temp,"t");
	strcat(temp,itoa_unix(tmp_cnt));
	fprintf(yyout, "%s = not %s\n",temp,st1[top--]);
 	fprintf(yyout, "if %s goto L%d\n",temp,label_num);
	tmp_cnt++;
	label[++ltop]=label_num;
	label_num++;
	fprintf(yyout, "goto L%d\n",label_num);
	label[++ltop]=label_num;
	label_num++;
	fprintf(yyout, "L%d:\n",label_num);
	label[++ltop]=label_num;
}
void for3()
{
	fprintf(yyout, "goto L%d\n",label[ltop-3]);
	fprintf(yyout, "L%d:\n",label[ltop-1]);
}
void for4()
{
	fprintf(yyout, "goto L%d\n",label[ltop]);
	fprintf(yyout, "L%d:\n",label[ltop-2]);
	ltop-=4;
}
void push(char *a)
{
	strcpy(st1[++top],a);
}
void array1()
{
	strcpy(temp,"t");
	strcat(temp,itoa_unix(tmp_cnt));
	fprintf(yyout, "%s = %s\n",temp,st1[top]);
	strcpy(st1[top],temp);
	tmp_cnt++;
	strcpy(temp,"t");
	strcat(temp,itoa_unix(tmp_cnt));
	fprintf(yyout, "%s = %s [ %s ] \n",temp,st1[top-1],st1[top]);
	top--;
	strcpy(st1[top],temp);
	tmp_cnt++;
}
void codegen()
{
	strcpy(temp,"t");
	strcat(temp,itoa_unix(tmp_cnt));
	fprintf(yyout, "%s = %s %s %s\n",temp,st1[top-2],st1[top-1],st1[top]);
	top-=2;
	strcpy(st1[top],temp);
	tmp_cnt++;
}
void codegen_umin()
{
	strcpy(temp,"t");
	strcat(temp,itoa_unix(tmp_cnt));
	fprintf(yyout, "%s = -%s\n",temp,st1[top]);
	top--;
	strcpy(st1[top],temp);
	tmp_cnt++;
}
void codegen_assign()
{
	fprintf(yyout, "%s = %s\n",st1[top-2],st1[top]);
	top-=2;
}
void codegen_arrayAssign()
{
	fprintf(yyout, "%s [ %s ] = %s\n", st1[top-3],st1[top-2], st1[top]);
	top-=3;
}
%}
%union {
	int ival;
	char *str;
	struct TreeNode* node;
}
%token<ival> INT FLOAT VOID
%token<str> ID NUM REAL STRING
%token WHILE IF RETURN PREPROC LE PRINT PRINTLN PRINTSP SCAND SCANF FUNCTION ARRAY ELSE FOR GE EQ AND OR BREAK
%token LBR RBR LBK RBK LP RP COMMA SEMI SB
%left LE GE EQ NEQ AND OR LABK RABK
%right VAL
%right UMINUS
%left PLUS MINUS MUL DIV
%start program
%type<node> start Function Declaration parameter_list parameter StmtList stmt index assignment1 consttype E T F
%type<node> if while for Type else array Idlist
%%

program : start{
	if($1->length != 0)
	{
		ROOT = $1;
		FILE *fp;
		fp = fopen("vis/tree.dot", "w");
		if(fp){
			fprintf(fp, "digraph G{\n");
			fprintf(fp, "node%d[label = %s]\n", count, "start");
			traverseTree(fp, ROOT, 0);
			fprintf(fp, "}");
			fclose(fp);
		}
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

Function : Type ID LP {if(strcmp($2+1, "main")) 
	fprintf(yyout, "F%d:\n", fnum++); 
	else fprintf(yyout, "Main:\n");
	insert($2+1,FUNCTION);
	insert($2+1,getType($1->val));
	insert($2+1,fnum);
} parameter_list{for(j=0;j<=k;j++) {insert_parameter($2+1,paraTypeList[j]);} k=-1;} RP LBR StmtList RBR  {
	$2 = $2 + 1;
	int type = getType($1->val);
	if (getType($1->val)!=returntype_func(ct))
	{
		printf("\nError : Type mismatch : Line %d\n",yylineno); 
		errc++;
	}
	struct TreeNode * child[4];
	child[0] = $1;
	child[1] = createTreeNode("ID", $2, NULL, 0);
	child[2] = $5;
	child[3] = $9;
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
	paraTypeList[++k]=getType($1->val);
	fprintf(yyout, "%s = a%d\n", $2, para_cnt++);
	$2 = $2+1;
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
Idlist : Idlist COMMA ID{
	struct TreeNode* child[2];
	child[0] = $1;
	child[1] = createTreeNode("ID", $3+1, NULL, 0);
	$$ = createTreeNode("Idlist", NULL, child, 2);
	$$->num = $1->num + 1;
	fprintf(yyout, ",%s", $3);
}
		| ID{
			struct TreeNode* child[1];
			child[0] = createTreeNode("ID", $1+1, NULL, 0);
			$$ = createTreeNode("Idlist", NULL, child, 1);
			$$->num = 1;
			fprintf(yyout, "%s", $1);
		
	}
		| {$$ = createTreeNode("Idlist", NULL, NULL, 0);}
		;

stmt : Declaration {struct TreeNode* child[1] = {$1}; $$ = createTreeNode("stmt", NULL, child, 1);}
	| if {struct TreeNode* child[1] = {$1}; $$ = createTreeNode("stmt", NULL, child, 1);}
	| while {struct TreeNode* child[1] = {$1}; $$ = createTreeNode("stmt", NULL, child, 1);}
	| for {struct TreeNode* child[1] = {$1}; $$ = createTreeNode("stmt", NULL, child, 1);}
	| PRINTSP LP NUM COMMA ID RP {
		struct TreeNode* child[3];
		child[0] = createTreeNode("PRINTSP", NULL, NULL, 0);
		child[1] = createTreeNode("NUM", $3, NULL, 0);
		child[2] = createTreeNode("ID", $5+1, NULL, 0);
		$$ = createTreeNode("stmt", NULL, child, 3);
		fprintf(yyout, "PRINTSP %s-%s\n", $3, $5);
	}
	| BREAK {
		struct TreeNode* child[1];
		child[0] = createTreeNode("BREAK", NULL, NULL, 0);
		$$ = createTreeNode("stmt", NULL, child, 1);
		fprintf(yyout, "goto L%d\n", breakFlag);
	}
	| RETURN consttype SEMI {
		struct TreeNode* child[2];
		child[0] = createTreeNode("RETURN", NULL, NULL, 0);
		child[1] = $2;
		$$ = createTreeNode("stmt", NULL, child, 2);
		fprintf(yyout, "RETURN %s\n", $2->val);
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
		fprintf(yyout, "RETURN %s\n", "VOID");
		storereturn(ct,VOID); 
		ct++;
}
	| RETURN ID SEMI {
		struct TreeNode* child[2];
		child[0] = createTreeNode("RETURN", NULL, NULL, 0);
		child[1] = createTreeNode("ID", $2+1, NULL, 0);
		$$ = createTreeNode("stmt", NULL, child, 2);
		fprintf(yyout, "RETURN %s\n", $2);
		$2 = $2+1;
		int sct=returnscope($2,stack[index1-1]);	//stack[index1-1] - current scope
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
	| SCAND {fprintf(yyout, "SCAND ");} LP Idlist RP SEMI {
		fprintf(yyout, "\n");
		struct TreeNode* child[2];
		child[0] = createTreeNode("SCAND", NULL, NULL, 0);
		child[1] = $4;
		$$ = createTreeNode("stmt", NULL, child, 2);
}
	| SCANF {fprintf(yyout, "SCANF ");} LP Idlist RP SEMI {
		fprintf(yyout, "\n");
		struct TreeNode* child[2];
		child[0] = createTreeNode("SCANF", NULL, NULL, 0);
		child[1] = $4;
		$$ = createTreeNode("stmt", NULL, child, 2);
}
	| PRINTLN LP STRING RP SEMI {
		struct TreeNode * child[2];
		fprintf(yyout, "PRINTSLN %s\n", $3);
		char * str1 = strdup("\"\\\"");
		char * str2 = strdup("\\\"\"");
		char * temp = (char *)malloc(sizeof(char) * (strlen($3)+1));
		strcpy(temp, $3);
		strcat(str1, temp);
		strcat(str1, str2);
		child[0] = createTreeNode("PRINTLN", NULL, NULL, 0);
		child[1] = createTreeNode("STRING", str1, NULL, 0);
		$$ = createTreeNode("stmt", NULL, child, 2);
	}
	| PRINTLN LP ID RP SEMI {
		struct TreeNode * child[2];
		fprintf(yyout, "PRINTILN %s\n", $3);
		char * temp = (char *)malloc(sizeof(char) * (strlen($3)+1));
		strcpy(temp, $3);
		child[0] = createTreeNode("PRINTLN", NULL, NULL, 0);
		child[1] = createTreeNode("STRING", temp+1, NULL, 0);
		$$ = createTreeNode("stmt", NULL, child, 2);
	}
	| PRINT LP STRING RP SEMI {
		struct TreeNode* child[2];
		fprintf(yyout, "PRINTS %s\n", $3);
		char * str1 = strdup("\"\\\"");
		char * str2 = strdup("\\\"\"");
		char * temp = (char *)malloc(sizeof(char) * (strlen($3)+1));
		strcpy(temp, $3);
		strcat(str1, temp);
		strcat(str1, str2);
		child[0] = createTreeNode("PRINT", NULL, NULL, 0);
		child[1] = createTreeNode("STRING", str1, NULL, 0);
		$$ = createTreeNode("stmt", NULL, child, 2);
}
	| PRINT LP ID RP SEMI {
		struct TreeNode* child[2];
		fprintf(yyout, "PRINTI %s\n", $3);
		char * temp = (char *)malloc(sizeof(char) * (strlen($3)+1));
		strcpy(temp, $3);
		child[0] = createTreeNode("PRINT", NULL, NULL, 0);
		child[1] = createTreeNode("ID", temp+1, NULL, 0);
		$$ = createTreeNode("stmt", NULL, child, 2);
}
	| LBR StmtList RBR {
		struct TreeNode* child[1] = {$2};
		$$ = createTreeNode("stmt", NULL, child, 1);
}
	| SB VAL ID LP {fprintf(yyout, "param ");} Idlist RP {
		int f_index = 0;
		if(!lookup($3+1))
		{
			for(int i=0;i<n;i++)
			{
				if(!strcmp($3+1,st[i].symbol_name))
				{
					f_index = st[i].symbol_type[st[i].type_num];
					if(st[i].parameter_num != $6->num)
					{
						printf("Error : Parameter Number doesn't math : Line %d\n", yylineno);
						errc++;
					}
					break;
				}
			}
			fprintf(yyout, "\ncall F%d\n",f_index);
		}
		else
		{
			printf("\nError : function not found : Line %d\n",yylineno);
			errc++;
		}
		struct TreeNode* child[4];
		child[0] = createTreeNode("SB", NULL, NULL, 0);
		child[1] = createTreeNode("VAL", "\"=\"", NULL, 0);
		child[2] = createTreeNode("ID", $3+1, NULL, 0);
		child[3] = $6;
		$$ = createTreeNode("stmt", "0", child, 4);
		$$->isFunc = 1;

	}	
	;


for	: FOR LP E {for1();} SEMI E {for2();}SEMI E {for3();} RP LBR StmtList RBR {for4();}
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

if : 	 IF LP E RP {if1();} LBR StmtList RBR {if2();} else {
	struct TreeNode* child[4];
	child[0] = createTreeNode("IF", NULL, NULL, 0);
	child[1] = $3;
	child[2] = $7; 
	child[3] = $10;
	$$ = createTreeNode("if", NULL, child, 4);
}
	;

else : ELSE LBR StmtList RBR {if3();} {
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

while : WHILE {while1();}LP E RP {while2();} LBR StmtList RBR {while3();} {
	struct TreeNode* child[3];
	child[0] = createTreeNode("WHILE", NULL, NULL, 0);
	child[1] = $4;
	child[2] = $8;
	$$ = createTreeNode("while", NULL, child, 3);
}
	;

index : ID {
	if(lookup($1+1))
	{
		printf("\nUndeclared Variable %s : Line %d\n",$1+1,yylineno);
		errc++;
	}
	struct TreeNode* child[1];
	child[0] = createTreeNode("ID", NULL, NULL, 0);
	$$ = createTreeNode("index", $1+1, child, 1);
}
	| consttype{
	struct TreeNode* child[1] = {$1};
	$$ = createTreeNode("index", $1->val, child, 1);
}
	;


assignment1 : ID {push($1);} VAL {push("=");} E {
		if($5->isFunc!=1)
		{
			codegen_assign();
		}
		else
		{
			fprintf(yyout, " -> %s\n", $1);
		}
		$1 = $1+1;
		struct TreeNode* child[3];
		child[0] = createTreeNode("ID", $1, NULL, 0);
		child[1] = createTreeNode("VAL", "\"=\"", NULL, 0);
		child[2] = $5;
		$$ = createTreeNode("assignment", $1, child, 3);
		int sct=returnscope($1,stack[index1-1]);
		int type=returntype($1,sct);
		if((!(strspn($5->val,"0123456789")==strlen($5->val))) && type==258 && fl==0)
		{
			printf("\nError : Type Mismatch : Line %d\n",yylineno);
			errc++;
		}
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
	| ID {push($1);} LBK E  RBK VAL {push("=");} E {
		codegen_arrayAssign();
		struct TreeNode* child[6];
		$1 = $1+1;
		child[0] = createTreeNode("ID", $1, NULL, 0);
		child[1] = createTreeNode("\"[\"", NULL, NULL, 0);
		child[2] = $4;
		child[3] = createTreeNode("\"]\"", NULL, NULL, 0);
		child[4] = createTreeNode("VAL", "\"=\"", NULL, 0);
		child[5] = $8;
		$$ = createTreeNode("assignment", $1, child, 6);
		int sct=returnscope($1,stack[index1-1]);
		int type=returntype($1,sct);
		if((!(strspn($8->val,"0123456789")==strlen($8->val))) && type==258 && fl==0)
		{
			printf("\nError : Type Mismatch : Line %d\n",yylineno);
			errc++;
		}
		if(!lookup($1))
		{
			int currscope=stack[index1-1];
			int scope=returnscope($1,currscope);
			if((scope<=currscope && end[scope]==0) && !(scope==0))
			{
				check_scope_update($1,$8->val,currscope);
			}
		}
	}
	;



consttype : NUM {$$ = createTreeNode("consttype", $1, NULL, 0);}
	| REAL {$$ = createTreeNode("consttype", $1, NULL, 0);}
	;

Declaration : Type ID {push($2);} VAL {push("=");} E {codegen_assign();} SEMI
	{
		int type = 0;
		struct TreeNode* child[4];
		$2 = $2+1;
		child[0] = $1;
		child[1] = createTreeNode("ID", $2, NULL, 0);
		child[2] = createTreeNode("\"=\"", NULL, NULL, 0);
		child[3] = $6;
		$$ = createTreeNode("Declaration", NULL, child, 4);
		if( (!(strspn($6->val,"0123456789")==strlen($6->val))) && getType($1->val)==258 && (fl==0))
		{
			printf("\nError : Type Mismatch : Line %d\n",yylineno);
			errc++;
			fl=1;
		}
		if(!lookup($2))
		{
			int currscope=stack[index1-1];
			int previous_scope=returnscope($2,currscope);
			if(currscope==previous_scope)
			{
				printf("\nError : Redeclaration of %s : Line %d\n",$2,yylineno);
				errc++;
			}
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
	| Type ID SEMI {
		$2 = $2 + 1;
		struct TreeNode* child[2];
		child[0] = $1;
		child[1] = createTreeNode("ID", $2, NULL, 0);
		$$ = createTreeNode("Declaration", NULL, child, 2);
		if(!strcmp($1->val, "INT"))
		{
			fprintf(yyout, "%s = 0\n", $2 - 1);
		}
		else if(!strcmp($1->val, "FLOAT"))
		{
			fprintf(yyout, "%s = 0.0\n", $2 - 1);
		}
		if(!lookup($2))
		{
			int currscope=stack[index1-1];
			int previous_scope=returnscope($2,currscope);
			if(currscope==previous_scope)
			{
				printf("\nError : Redeclaration of %s : Line %d\n",$2,yylineno);
				errc++;
			}
			else
			{
				insert_dup($2,getType($1->val),currscope);
				int sg=returnscope($2,stack[index1-1]);
			}
		}
		else
		{
			int scope=stack[index1-1];
			insert($2,getType($1->val));
			insertscope($2,scope);
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
			{
				printf("\nError : Variable %s out of scope : Line %d\n",$1->val,yylineno);
				errc++;
			}
		}
		else
		{
			printf("\nError : Undeclared Variable %s : Line %d\n",$1->val,yylineno);
			errc++;
		}
		}

		| Type ID LBK index RBK SEMI {
			$2 = $2+1;
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
			else
			{
				if(!strcmp($1->val, "INT"))
				{
					fprintf(yyout, "DECLI %s:%s\n", $2-1, $4->val);
				}
				else if(!strcmp($1->val, "FLOAT"))
				{
					fprintf(yyout, "DECLF %s:%s\n", $2-1, $4->val);
				}
			}
			if(atoi($4->val)<=0)
			{ printf("\nError : Array index must be of type int > 0 : Line %d\n",yylineno);errc++;}
			if(!lookup($2))
			{
				int currscope=stack[index1-1];
				int previous_scope=returnscope($2,currscope);
				if(currscope==previous_scope)
				{printf("\nError : Redeclaration of %s : Line %d\n",$2,yylineno);errc++;}
				else
				{
					insert_dup($2,ARRAY,currscope);
					insert_by_scope($2,getType($1->val),currscope);	//to insert type to the correct identifier in case of multiple entries of the identifier by using scope
					if (itype==258) {insert_index($2,atoi($4->val));}
				}
			}
			else
			{
				int scope=stack[index1-1];
				insert($2,ARRAY);
				insert($2,getType($1->val));
				insertscope($2,scope);
				if (itype==258) {insert_index($2,atoi($4->val));}
			}
		}
	| error {}
	;

array : ID {push($1);}LBK E RBK{
	struct TreeNode* child[2];
	child[0] = createTreeNode("ID", $1+1, NULL, 0);
	child[1] = $4;
	$$ = createTreeNode("Array", $1+1, child, 2);
}
	;

E :  E PLUS{push("+");} T
{
	codegen();
	struct TreeNode* child[3];
	char * temp = (char *)malloc(strlen($1->val)*sizeof(char));
	strcpy(temp, $1->val);
	strcat(temp, $4->val);
	child[0] = $1;
	child[1] = createTreeNode("\"+\"", NULL, NULL, 0);
	child[2] = $4;
	$$ = createTreeNode("E", temp, child, 3);
}
   | E MINUS{push("-");} T
{
	codegen();
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
   | ID {push($1);} LE 		{push("<=");} E {
	codegen();
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1+1, NULL, 0);
	child[1] = createTreeNode("\"<=\"", NULL, NULL, 0);
	child[2] = $5;
	$$ = createTreeNode("E", $5->val, child, 3);
}
   | ID {push($1);} GE 		{push(">=");} E {
	codegen();
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1+1, NULL, 0);
	child[1] = createTreeNode("\">=\"", NULL, NULL, 0);
	child[2] = $5;
	$$ = createTreeNode("E", $5->val, child, 3);
}
   | ID {push($1);} EQ 		{push("==");} E {
	codegen();
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1+1, NULL, 0);
	child[1] = createTreeNode("\"==\"", NULL, NULL, 0);
	child[2] = $5;
	$$ = createTreeNode("E", $5->val, child, 3);
}
   | ID {push($1);} NEQ 	{push("!=");} E {
	codegen();
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1+1, NULL, 0);
	child[1] = createTreeNode("\"!=\"", NULL, NULL, 0);
	child[2] = $5;
	$$ = createTreeNode("E", $5->val, child, 3);
}
   | ID {push($1);} AND 	{push("&&");} E {
	codegen();
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1+1, NULL, 0);
	child[1] = createTreeNode("\"&&\"", NULL, NULL, 0);
	child[2] = $5;
	$$ = createTreeNode("E", $5->val, child, 3);
}
   | ID {push($1);} OR 		{push("||");} E {
	codegen();
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1+1, NULL, 0);
	child[1] = createTreeNode("\"||\"", NULL, NULL, 0);
	child[2] = $5;
	$$ = createTreeNode("E", $5->val, child, 3);
}
   | ID {push($1);} LABK 	{push("<");}  E {
	codegen();
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1+1, NULL, 0);
	child[1] = createTreeNode("\"<\"", NULL, NULL, 0);
	child[2] = $5;
	$$ = createTreeNode("E", $5->val, child, 3);
}
   | ID {push($1);} RABK 	{push(">");}  E {
	codegen();
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1+1, NULL, 0);
	child[1] = createTreeNode("\">\"", NULL, NULL, 0);
	child[2] = $5;
	$$ = createTreeNode("E", NULL, child, 3);
}
   | ID {push($1);} VAL 	{push("=");}  E {
	codegen_assign();
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1+1, NULL, 0);
	child[1] = createTreeNode("\"=\"", NULL, NULL, 0);
	child[2] = $5;
	$$ = createTreeNode("E", $5->val, child, 3);
}
	| ID {push($1);} LP {fprintf(yyout, "param ");} Idlist RP{
		int f_index = 0;
		if(!lookup($1+1))
		{
			for(int i=0;i<n;i++)
			{
				if(!strcmp($1+1,st[i].symbol_name))
				{
					f_index = st[i].symbol_type[st[i].type_num];
					if(st[i].parameter_num != $5->num)
					{
						printf("Error: Parameter Number doesn't math Line : %d\n", yylineno);
						errc++;
					}
					break;
				}
			}
			fprintf(yyout, "\ncall F%d",f_index);
		}
		else
		{
			printf("\nError : function not found : Line %d\n",yylineno);
			errc++;
		}
		struct TreeNode* child[2];
		child[0] = createTreeNode("ID", $1+1, NULL, 0);
		child[1] = $5;
		$$ = createTreeNode("E", "0", child, 2);
		$$->isFunc = 1;
	}
   | array {
	array1();
	struct TreeNode* child[1] = {$1};
	$$ = createTreeNode("E", $1->val, child, 1);
}
   ;


T :  T MUL{push("*");} F
{
	codegen();
	struct TreeNode* child[3];
	char * temp = (char *)malloc(strlen($1->val)*sizeof(char));
	strcpy(temp, $1->val);
	strcat(temp, $4->val);
	child[0] = $1;
	child[1] = createTreeNode("\"*\"", NULL, NULL, 0);
	child[2] = $4;
	$$ = createTreeNode("T", temp, child, 3);
}
   | T DIV{push("/");} F
{
	codegen();
	struct TreeNode* child[3];
	char * temp = (char *)malloc(strlen($1->val)*sizeof(char));
	strcpy(temp, $1->val);
	strcat(temp, $4->val);
	child[0] = $1;
	child[1] = createTreeNode("\"/\"", NULL, NULL, 0);
	child[2] = $4;
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
   | MINUS{push("-");} F{codegen_umin();} %prec UMINUS{
	   struct TreeNode* child[2];
	   child[0] = createTreeNode("\"-\"", NULL, NULL, 0);
	   child[1] = $3;
	   $$=createTreeNode("F", $3->val, child, 2);
   }
   | ID {
	   struct TreeNode* child[1];
	   char *temp = strdup($1);
	   child[0] = createTreeNode("ID", temp+1, NULL, 0);
	   $$=createTreeNode("F", $1, child, 1);
	   push($1);
	   fl=1;
}
   | consttype {
	   push($1->val);
	   struct TreeNode* child[1] = {$1};
	   $$=createTreeNode("F", $1->val, child, 1);
}
   ;

%%

#include "lex.yy.c"
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

int yywrap()
{
	return 1;
}
int main(int argc, char *argv[])
{
	int ptr = 0;
	yyin =fopen(argv[1],"r");
	int len = strlen(argv[1])-2;
	char temp[40];
	char * dest = (char *)malloc(sizeof(char) * 20);
	strcpy(temp, "IR/");
	strcpy(dest, argv[1]);
	for(int i = 0;i<strlen(argv[1]);i++)
	{
		if(argv[1][i] == '/')
		{
			ptr = i;
		}
	}
	dest += ptr+1;
	strcat(dest,".tac");
	strcat(temp, dest);
	yyout = fopen(temp, "w+");
	/* yyparse(); */
	if(!yyparse())
	{
		printf("\nParsing Done With %d Error\n", errc);
	}
	fclose(yyout);
	fclose(yyin);
	return 0;
}

void yyerror(char *s)
{
	printf("\nLine %d : %s %s\n",yylineno,s,yytext);
}
