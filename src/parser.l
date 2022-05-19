%{
int yylineno;
%}

alpha [A-Za-z]
digit [0-9]
reg t[0-9]+

%%
[ \t] ;
\n	{yylineno++;}

"{"     {scope_start(); return LBR; }
"}"     {scope_end(); return RBR; }
"["     return LBK;
"]"     return RBK;
"("     return LP;
")"     return RP;
"<"     return LABK;
">"     return RABK;
","     return COMMA;
";"     return SEMI;
"+"     return PLUS;
"-"     return MINUS;
"*"     return MUL;
"/"     return DIV;
"="     return VAL;
"<="	return LE;
">="	return GE;
"=="	return EQ;
"!="	return NEQ;
"&&"	return AND;
"||"	return OR;
"!"		return SB;

int	{yylval.ival = INT; return INT;}
float	{yylval.ival = FLOAT; return FLOAT;}
void	{yylval.ival = VOID; return VOID;}
else	{return ELSE;}
if	return IF;
"#include ".+	{
	return PREPROC;}
while	return WHILE;
break return BREAK;
for	return FOR;
return 	return RETURN;
print	return PRINT;
println return PRINTLN;
printsp return PRINTSP;
scanf return SCANF;
scand return SCAND;
({alpha}|_)({alpha}|{digit}|_)* {
	char * temp = strdup("%");
	strcat(temp, yytext);
	yylval.str=temp; 
	return ID;}
{digit}+	{yylval.str=strdup(yytext);return NUM;}
{digit}+\.{digit}+ 	{yylval.str=strdup(yytext); return REAL;}

\/\/.* ;
\/\*(.*\n)*.*\*\/ ;

\"[^"]*\"	{
	int len = strlen(yytext);
	char * temp = strdup(yytext);
	char * temp2 = (char *)malloc(sizeof(char) * len);
	strncpy(temp2, temp+1, len-2);
	yylval.str = temp2;
	// printf("TEST:%s", temp2);
	return STRING;}
.	return yytext[0];
%%
