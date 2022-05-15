%{
int yylineno;
%}

alpha [A-Za-z]
digit [0-9]


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
"%"     return MOD;
"="     return VAL;
"<="	return LE;
">="	return GE;
"=="	return EQ;
"!="	return NEQ;
"&&"	return AND;
"||"	return OR;

int	{yylval.ival = INT; return INT;}
float	{yylval.ival = FLOAT; return FLOAT;}
void	{yylval.ival = VOID; return VOID;}
else	{return ELSE;}
do	return DO;
if	return IF;
struct 	return STRUCT;
^"#include ".+	return PREPROC;
while	return WHILE;
for	return FOR;
return 	return RETURN;
printf	return PRINT;
{alpha}({alpha}|{digit})* {yylval.str=strdup(yytext); return ID;}
{digit}+	{yylval.str=strdup(yytext);return NUM;}
{digit}+\.{digit}+ 	{yylval.str=strdup(yytext); return REAL;}

\/\/.* ;
\/\*(.*\n)*.*\*\/ ;

\".*\"	return STRING;
.	return yytext[0];
%%
