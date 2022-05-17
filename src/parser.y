%{
#include <stdio.h>
#include <stdlib.h>
#include "symbolTable.c"
#include "Tree.h"
/*
Global Variables:
-----------------
scopeNum: the scope number, every scope has a unique scope number
mfDeclared: the bool flag representing if have declared the Main function
mfLine: the line number of main function entry
stack[]: the stack to store the scope number
stack_top: the top pointer of the stack
end[]: the table representing whether the scope ends, the index is the scope number. 1 is ended, 0 is not 
-----------------
*/
int scopeNum=1;
int mfDeclared = 0, mfLine = 0;
int stack[100],stack_top=0,end[100],arr[10],ct,c,b,fl,top=0,label[20],label_num=0,ltop=0;
int k=-1,errc=0,j=0;

extern int yylineno;

//中间代码输出控件
char st1[100][10];
int tmp_cnt = 0;
char temp[2]="t";

void yyerror(char *s);

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
struct TreeNode * createTreeNode(char * type, char * val, struct TreeNode ** child)
{
	struct TreeNode * node = (struct TreeNode *)malloc(sizeof(struct TreeNode));
	node->val = val;
	node->type = type;
	node->child = child;
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
/*
scope_start:
After entering a scope, push the scope number into the stack and increase the scopeNum
*/
void scope_start()
{
	stack[stack_top]=scopeNum;
	scopeNum++;
	stack_top++;
	return;
}
/*
scope_end:
After quit the scope, pop the stack and make this scope end by updating end-array
*/
void scope_end()
{
	stack_top--;
	end[stack[stack_top]]=1;
	stack[stack_top]=0;
	return;
}
void if1()
{
	label_num++;
	
	strcpy(temp,"t");
	strcat(temp,itoa_unix(tmp_cnt));
	printf("\n%s = not %s\n",temp,st1[top]);
 	printf("if %s goto L%d\n",temp,label_num);
	tmp_cnt++;
	label[++ltop]=label_num;

}
void if2()
{
	label_num++;
	printf("\ngoto L%d\n",label_num);
	printf("L%d: \n",label[ltop--]);
	label[++ltop]=label_num;
}
void if3()
{
	printf("\nL%d:\n",label[ltop--]);
}
void while1()
{
	label_num++;
	label[++ltop]=label_num;
	printf("\nL%d:\n",label_num);
}
void while2()
{
	label_num++;
	strcpy(temp,"t");
	strcat(temp,itoa_unix(tmp_cnt));
	printf("\n%s = not %s\n",temp,st1[top--]);
 	printf("if %s goto L%d\n",temp,label_num);
	tmp_cnt++;
	label[++ltop] = label_num;
}
void while3() 
{
	int y=label[ltop--];
	printf("\ngoto L%d\n",label[ltop--]);
	printf("L%d:\n",y);
}
void for1()
{
	label_num++;
	label[++ltop]=label_num;
	printf("\nL%d:\n",label_num);
}
void for2()
{
	label_num++;
	strcpy(temp,"t");
	strcat(temp,itoa_unix(tmp_cnt));
	printf("\n%s = not %s\n",temp,st1[top--]);
 	printf("if %s goto L%d\n",temp,label_num);
	tmp_cnt++;
	label[++ltop]=label_num;
	label_num++;
	printf("goto L%d\n",label_num);
	label[++ltop]=label_num;
	label_num++;
	printf("L%d:\n",label_num);
	label[++ltop]=label_num;
}
void for3()
{
	printf("\ngoto L%d\n",label[ltop-3]);
	printf("L%d:\n",label[ltop-1]);
}
void for4()
{
	printf("\ngoto L%d\n",label[ltop]);
	printf("L%d:\n",label[ltop-2]);
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
	printf("\n%s = %s\n",temp,st1[top]);
	strcpy(st1[top],temp);
	tmp_cnt++;
	strcpy(temp,"t");
	strcat(temp,itoa_unix(tmp_cnt));
	printf("%s = %s [ %s ] \n",temp,st1[top-1],st1[top]);
	top--;
	strcpy(st1[top],temp);
	tmp_cnt++;
}
void codegen()
{
	strcpy(temp,"t");
	strcat(temp,itoa_unix(tmp_cnt));
	printf("\n%s = %s %s %s\n",temp,st1[top-2],st1[top-1],st1[top]);
	top-=2;
	strcpy(st1[top],temp);
	tmp_cnt++;
}
void codegen_umin()
{
	strcpy(temp,"t");
	strcat(temp,itoa_unix(tmp_cnt));
	printf("\n%s = -%s\n",temp,st1[top]);
	top--;
	strcpy(st1[top],temp);
	tmp_cnt++;
}
void codegen_assign()
{
	printf("\n%s = %s\n",st1[top-2],st1[top]);
	top-=2;
}
%}
%union {
	int ival;
	char *str;
	struct TreeNode * node;
}
%token<ival> INT FLOAT VOID
%token<str> ID NUM REAL STRING
%token WHILE IF RETURN PREPROC LE PRINT  ELSE FOR GE EQ AND OR
%token LBR RBR LBK RBK LP RP COMMA SEMI 
%left LE GE EQ NEQ AND OR LABK RABK
%right VAL
%right UMINUS
%left PLUS MINUS MUL DIV
%type<node> start Function Declaration parameter_list parameter StmtList stmt index assignment consttype E T F
%type<node> if while for Type else array 
%%
/*
start -> PREPROC start: #include <XXX.h>
start -> Function start: Function declaration
start -> Declaration start: variable declaration 
*/
start : PREPROC start{
		// printf("s->P s");
		struct TreeNode * child[2];
		struct TreeNode * temp = createTreeNode("PREPROC", NULL, NULL);
		child[1] = temp;
		child[2] = $2;
		$$ = createTreeNode("start", NULL, child); 
	}
	| Function start
	{
		// printf("s->F s");
		struct TreeNode * child[2] = {$1, $2};
		$$ = createTreeNode("start", NULL, child);
	}
	| Declaration start
	{
		// printf("s->D s");
		struct TreeNode * child[2] = {$1, $2};
		$$ = createTreeNode("start", NULL, child);
	}
	| {$$ = createTreeNode("start", NULL, NULL);}
	;
//The function declaration eg. int sum(int x, int y){return 1;}
Function : Type ID LP parameter_list RP LBR StmtList RBR { 
		int nameError = 0;
		int type = getType($1->val);
		if(strcmp($2,"main") == 0) //If it's the main function, then check if we have declared a main function
		{
			if(mfDeclared == 0) // if not, then print note
			{
				mfLine = yylineno;
				mfDeclared = 1;
				printf("Enter Main Function in Line %d\n", yylineno);
			}
			else // if yes, then print the error information
			{
				printf("Error: There has exited a Main Function in Line %d", yylineno);
				nameError = 1;
				errc++;
			}
		}
		else // if it's not a main function, then print note and insert the function name into the symbol table
		{
			printf("Enter Function '%s' in Line %d\n", $2, yylineno);
			insert($2,FUNCTION);
			insert($2,type);
		}
		if (type!=returntype_func(ct)) //Check if the return value matches the Type in function declaration
		{
			printf("Type is: %d, and rt is : %d", type, returntype_func(ct));
			printf("\nError : Type mismatch : Line %d\n",yylineno);
			errc++;
		}
		if (nameError == 0)
		{
			struct TreeNode * child[4];
			child[0] = $1;
			child[1] = createTreeNode("ID", $2, NULL);
			child[2] = $4;
			child[3] = $7;
			$$ = createTreeNode("Function", $2, child);
		}
	};
// parameter_list -- The list of parameters, delimited by ','(COMMA)
parameter_list : parameter_list COMMA parameter{
		struct TreeNode * child[2] = {$1, $3};
		$$ = createTreeNode("parameter_list", NULL, child);
	}
	        	| parameter{
		struct TreeNode * child[1] = {$1};
		$$ = createTreeNode("parameter_list", NULL, child);			
	}
	            ;
// paramter -- The representation of the parameter eg. int x
parameter : Type ID {
				// plist[++k] = $1;
				int type = getType($1->val);
				insert($2,type);
				insertscope($2,scopeNum);
				struct TreeNode * child[2];
				child[0] = $1;
				child[1] = createTreeNode("ID", $2, NULL);
				$$ = createTreeNode("parameter", $2, child);
			}
			|{$$ = createTreeNode("parameter", NULL, NULL);}
	        ;
// Type -- the type of the variable or return value, including 'int', 'float' and 'void'
// Can be updated: Add more types(char,..) pointer?
Type : INT {$$ = createTreeNode("INT", "INT", NULL);}
	| FLOAT{$$ = createTreeNode("FLOAT", "FLOAT", NULL);}
	| VOID {$$ = createTreeNode("VOID", "VOID", NULL);}
	;
// StmtList -- the list of statements
StmtList : StmtList stmt{
	struct TreeNode * child[2] = {$1, $2};
	$$ = createTreeNode("StmtList", NULL, child);
}
	|{$$ = createTreeNode("StmtList", NULL, NULL);}
	;
// stmt -- the statements in C
stmt : Declaration {struct TreeNode* child[1] = {$1}; $$ = createTreeNode("stmt", NULL, child);}
	| if {struct TreeNode* child[1] = {$1}; $$ = createTreeNode("if", NULL, child);}
	| ID LP RP SEMI{
		struct TreeNode* child[1]; 
		child[0] = createTreeNode("ID", $1, NULL); 
		$$ = createTreeNode("stmt", NULL, child);
	}
	| while {struct TreeNode* child[1] = {$1}; $$ = createTreeNode("while", NULL, child);}
	/* | dowhile {struct TreeNode* child[1] = {$1}; $$ = createTreeNode("dowhile", NULL, child);} */
	| for {struct TreeNode* child[1] = {$1}; $$ = createTreeNode("for", NULL, child);}
	| RETURN consttype SEMI {
		struct TreeNode* child[2];
		child[0] = createTreeNode("RETURN", NULL, NULL);
		child[1] = $2;
		$$ = createTreeNode("stmt", NULL, child);
		printf("Test const:%s", $2->val);
		// if(!(strspn($2->val,"0123456789")==strlen($2->val)))
		// 	storereturn(ct,FLOAT);
		// else
		// 	storereturn(ct,INT);
		ct++;
	}
	| RETURN SEMI {
		struct TreeNode* child[1];
		child[0] = createTreeNode("RETURN", NULL, NULL);
		$$ = createTreeNode("stmt", NULL, child);
		storereturn(ct,VOID); 
		ct++;
	}
	| RETURN ID SEMI {
		struct TreeNode* child[2];
		child[0] = createTreeNode("RETURN", NULL, NULL);
		child[1] = createTreeNode("ID", $2, NULL);
		$$ = createTreeNode("stmt", NULL, child);
		int sct=returnscope($2,stack[stack_top-1]);	//stack[top-1] - current scope
		int type=returntype($2,sct);
		if (type==259) storereturn(ct,FLOAT);
		else storereturn(ct,INT);
		ct++;
    }
	|SEMI {struct TreeNode* child[1];
		   child[0] = createTreeNode("SEMI", NULL, NULL);
		   $$ = createTreeNode("stmt", NULL, child);
		   }
	| PRINT LP ID RP SEMI{
		struct TreeNode* child[2];
		child[0] = createTreeNode("PRINT", NULL, NULL);
		child[1] = createTreeNode("ID", $3, NULL);
		$$ = createTreeNode("stmt", NULL, child);
	}
	| PRINT LP STRING RP SEMI{
		struct TreeNode* child[2];
		child[0] = createTreeNode("PRINT", NULL, NULL);
		child[1] = createTreeNode("STRING", $3, NULL);
		$$ = createTreeNode("stmt", NULL, child);
	}
	| LBR StmtList RBR{
		struct TreeNode* child[1] = {$2};
		$$ = createTreeNode("stmt", NULL, child);
	}
	;

/* dowhile : DO {dowhile1();} LBR StmtList RBR WHILE LP E RP {dowhile2();} SEMI
	; */

for	: FOR LP E {for1();} SEMI E {for2();}SEMI E {for3();} RP LBR StmtList RBR {
	for4();
	struct TreeNode* child[5];
	child[0] = createTreeNode("FOR", NULL, NULL);
	child[1] = $3;
	child[2] = $6;
	child[3] = $9;
	child[4] = $13;
	$$ = createTreeNode("for", NULL, child);
}
	;

if : 	 IF LP E RP {if1();} LBR StmtList RBR {if2();} else{
	printf("TESTif");
	struct TreeNode* child[4];
	child[0] = createTreeNode("IF", NULL, NULL);
	child[1] = $3;
	child[2] = $7; 
	child[3] = $10;
	$$ = createTreeNode("if", NULL, child);
}
	;

else : ELSE LBR StmtList RBR {if3();} {
	struct TreeNode* child[2];
	child[0] = createTreeNode("ELSE", NULL, NULL);
	child[1] = $3;
	$$ = createTreeNode("else", NULL, child);
}
	|{
	$$ = createTreeNode("else", NULL, NULL);
}
	;

while : WHILE {while1();}LP E RP {while2();} LBR StmtList RBR {while3();}{
	struct TreeNode* child[3];
	child[0] = createTreeNode("WHILE", NULL, NULL);
	child[1] = $4;
	child[2] = $8;
	$$ = createTreeNode("while", NULL, child);
}
	;

index : ID {
	if(lookup($1))
	printf("\nUndeclared Variable %s : Line %d\n",$1,yylineno);
	struct TreeNode* child[1];
	child[0] = createTreeNode("ID", NULL, NULL);
	$$ = createTreeNode("index", NULL, child);
}
	| consttype{
	struct TreeNode* child[1] = {$1};
	$$ = createTreeNode("index", $1->val, child);
}
	;

assignment : ID {push($1);} VAL {push("=");} E {codegen_assign();}
	{
		struct TreeNode* child[3];
		child[0] = createTreeNode("ID", $1, NULL);
		child[1] = createTreeNode("VAL", NULL, NULL);
		child[2] = $5;
		$$ = createTreeNode("assignment", $1, child);
		int sct=returnscope($1,stack[stack_top-1]);
		int type=returntype($1,sct);
		printf("Test E:%s", $5->val);
		if((!(strspn($5->val,"0123456789")==strlen($5->val))) && type==258 && fl==0)
		 	printf("\nError : Type Mismatch : Line %d\n",yylineno);
		if(!lookup($1))
		{
			int currscope=stack[stack_top-1];
			int scope=returnscope($1,currscope);
			if((scope<=currscope && end[scope]==0) && !(scope==0))
			{
				check_scope_update($1,$5->val,currscope);
			}
		}
	}
	;



consttype : NUM {$$ = createTreeNode("NUM", $1, NULL);}
	| REAL {$$ = createTreeNode("REAL", $1, NULL);}
	;

Declaration : Type ID {push($2);} VAL {push("=");} E {codegen_assign();} SEMI
	{
		int type = 0;
		struct TreeNode* child[4];
		child[0] = $1;
		child[1] = createTreeNode("ID", $2, NULL);
		child[2] = createTreeNode("=", NULL, NULL);
		child[3] = $6;
		$$ = createTreeNode("Declaration", NULL, child);
		printf("The val of E is %s", $6->val);
		if( (!(strspn($6->val,"0123456789")==strlen($6->val))) && getType($1->val)==258 && (fl==0))
		 {
		 	printf("\nError : Type Mismatch : Line %d\n",yylineno);
		 	fl=1;
		 }
		if(!lookup($2))
		{
			int currscope=stack[stack_top-1];
			int previous_scope=returnscope($2,currscope);
			if(currscope==previous_scope)
				printf("\nError : Redeclaration of %s : Line %d\n",$2,yylineno);
			else
			{
				insert_dup($2,getType($1->val),currscope);
				check_scope_update($2,$6->val,stack[stack_top-1]);
				int sg=returnscope($2,stack[stack_top-1]);
			}
		}
		else
		{
			int scope=stack[stack_top-1];
			insert($2,getType($1->val));
			insertscope($2,scope);
			check_scope_update($2,$6->val,stack[stack_top-1]);
		}
	}

	| assignment SEMI  {
		struct TreeNode* child[1] = {$1};
		$$ = createTreeNode("declaration", NULL, child);
		if(!lookup($1->val))
		{
			int currscope=stack[stack_top-1];
			int scope=returnscope($1->val,currscope);
			if(!(scope<=currscope && end[scope]==0) || scope==0)
				printf("\nError : Variable %s out of scope : Line %d\n",$1->val,yylineno);
		}
		else
			printf("\nError : Undeclared Variable %s : Line %d\n",$1->val,yylineno);
	}

		| Type ID LBK index RBK SEMI {
			struct TreeNode* child[3];
			child[0] = $1;
			child[1] = createTreeNode("ID", $2, NULL);
			child[2] = $4;
			$$ = createTreeNode("declaration", NULL, child);
			int itype = 258;
			if(!(strspn($4->val,"0123456789")==strlen($4->val))) 
				itype=259;
			else itype = 258;

			if(itype!=258)
			{ printf("\nError : Array index must be of type int : Line %d\n",yylineno);errc++;}
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
	| error
	;

array : ID {push($1);}LBK E RBK{
	struct TreeNode* child[2];
	child[0] = createTreeNode("ID", $1, NULL);
	child[1] = $4;
	$$ = createTreeNode("Array", $1, child);
}
	;

E :  E PLUS{push("+");} T{codegen();}
{
	struct TreeNode* child[3];
	char * temp = (char *)malloc(strlen($1->val)*sizeof(char));
	strcpy(temp, $1->val);
	strcat(temp, $4->val);
	child[0] = $1;
	child[1] = createTreeNode("+", NULL, NULL);
	child[2] = $4;
	$$ = createTreeNode("E", temp, child);
}
   | E MINUS{push("-");} T{codegen();}
{
	struct TreeNode* child[3];
	char * temp = (char *)malloc(strlen($1->val)*sizeof(char));
	strcpy(temp, $1->val);
	strcat(temp, $4->val);
	child[0] = $1;
	child[1] = createTreeNode("-", NULL, NULL);
	child[2] = $4;
	$$ = createTreeNode("E", temp, child);
}
   | T
{
	// printf("TESTt");
	struct TreeNode* child[1] = {$1};
	$$ = createTreeNode("E", $1->val, child);
}
   | ID {push($1);} LE {push("<=");} E {codegen();}
{
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1, NULL);
	child[1] = createTreeNode("<=", NULL, NULL);
	child[2] = $5;
	$$ = createTreeNode("E", $5->val, child);
}
   | ID {push($1);} GE  {push(">=");} E {codegen();}
{
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1, NULL);
	child[1] = createTreeNode(">=", NULL, NULL);
	child[2] = $5;
	$$ = createTreeNode("E", $5->val, child);
}
   | ID {push($1);} EQ  {push("==");} E {codegen();}
{
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1, NULL);
	child[1] = createTreeNode("==", NULL, NULL);
	child[2] = $5;
	$$ = createTreeNode("E", $5->val, child);
}
   | ID {push($1);} NEQ {push("!=");} E {codegen();}
{
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1, NULL);
	child[1] = createTreeNode("!=", NULL, NULL);
	child[2] = $5;
	$$ = createTreeNode("E", $5->val, child);
}
   | ID {push($1);} AND {push("&&");} E {codegen();}
{
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1, NULL);
	child[1] = createTreeNode("&&", NULL, NULL);
	child[2] = $5;
	$$ = createTreeNode("E", $5->val, child);
}
   | ID {push($1);} OR 	{push("||");} E {codegen();}
{
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1, NULL);
	child[1] = createTreeNode("||", NULL, NULL);
	child[2] = $5;
	$$ = createTreeNode("E", $5->val, child);
}
   | ID {push($1);} LABK {push("<");}  E {codegen();}
{
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1, NULL);
	child[1] = createTreeNode("<", NULL, NULL);
	child[2] = $5;
	$$ = createTreeNode("E", $5->val, child);
}
   | ID {push($1);} RABK {push(">");}  E {codegen();}
{
	// printf("TEST");
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1, NULL);
	child[1] = createTreeNode(">", NULL, NULL);
	child[2] = $5;
	$$ = createTreeNode("E", NULL, child);
}
   | ID {push($1);} VAL {push("=");}  E {codegen_assign();}
{
	struct TreeNode* child[3];
	child[0] = createTreeNode("ID", $1, NULL);
	child[1] = createTreeNode("=", NULL, NULL);
	child[2] = $5;
	$$ = createTreeNode("E", $5->val, child);
}
   | array {
	array1();
	struct TreeNode* child[1] = {$1};
	$$ = createTreeNode("E", $1->val, child);
}
   ;
T :  T MUL{push("*");} F{codegen();}
{
	struct TreeNode* child[3];
	char * temp = (char *)malloc(strlen($1->val)*sizeof(char));
	strcpy(temp, $1->val);
	strcat(temp, $4->val);
	child[0] = $1;
	child[1] = createTreeNode("*", NULL, NULL);
	child[2] = $4;
	$$ = createTreeNode("T", temp, child);
}
   | T DIV{push("/");} F{codegen();}
{
	struct TreeNode* child[3];
	char * temp = (char *)malloc(strlen($1->val)*sizeof(char));
	strcpy(temp, $1->val);
	strcat(temp, $4->val);
	child[0] = $1;
	child[1] = createTreeNode("/", NULL, NULL);
	child[2] = $4;
	$$ = createTreeNode("T", temp, child);
}
   | F
{
	// printf("TESTf");
	struct TreeNode* child[1] = {$1};
	$$ = createTreeNode("T", $1->val, child);
}
   ;
F :  LP E RP {
	struct TreeNode* child[3];
	child[0] = createTreeNode("(", NULL, NULL);
	child[1] = $2;
	child[2] = createTreeNode(")", NULL, NULL);
	$$=createTreeNode("F", $2->val, child);
}
   | MINUS{push("-");} F{codegen_umin();} %prec UMINUS{
	   struct TreeNode* child[2];
	   child[0] = createTreeNode("-", NULL, NULL);
	   child[1] = $3;
	   $$=createTreeNode("F", $3->val, child);
   }
   | ID {
	   struct TreeNode* child[1];
	   child[0] = createTreeNode("ID", $1, NULL);
	   $$=createTreeNode("F", $1, child);
	   push($1);
	   fl=1;
   }
   | consttype {
	   printf("TESTc");
	   push($1->val);
	   struct TreeNode* child[1] = {$1};
	   $$=createTreeNode("F", $1->val, child);
	}
   ;

%%

#include "lex.yy.c"
#include<ctype.h>


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
