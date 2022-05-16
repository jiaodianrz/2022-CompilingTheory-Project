#include<stdio.h>
#include<string.h>
struct symbolTable
{
	int 	symbol_no;		//symbol编号
	char 	symbol_name[50];//项的名称
	int 	symbol_type[100], parameter_type[100];	//symbol类型，参数类型维护
	int 	type_num, parameter_num;				//类型数量，参数数量
	int 	index, scope;
	float	f_value;

}st[100];

int n=0;
int return_array[10];
float t[100];
int iter=0;

//根据指定下标返回函数的类型
int returntype_func(int ct)
{
	return return_array[ct-1];
}
//根据指定下标存储返回类型
void storereturn( int ct, int returntype )
{
	return_array[ct] = returntype;
	return;
}
//更改symbol_table的scope, 使其变为最新的
void insertscope(char *a,int f_scope)
{
	int i;
	for(i=0;i<n;i++)
	{
		if(!strcmp(a,st[i].symbol_name))
		{
			st[i].scope=f_scope;
			break;
		}
	}
}
//返回距离cs前相应symbol table最近的scope
int returnscope(char *a,int cs)
{
	int i, max = 0;
	for(i=0;i<=n;i++)
	{
		if(!(strcmp(a,st[i].symbol_name)) && cs>=st[i].scope)
		{
			if(st[i].scope>=max)
				max = st[i].scope;
		}
	}
	return max;
}
//查询token_ID是否在symbol_table中
int lookup(char *a)
{
	int i;
	for(i=0;i<n;i++)
	{
		if( !strcmp( a, st[i].symbol_name) )
			return 0;
	}
	return 1;
}
//查询token_ID的返回类型
int returntype(char *a,int sct)
{
	int i;
	for(i=0;i<=n;i++)
	{
		if(!strcmp(a,st[i].symbol_name) && st[i].scope==sct)
		{
			return st[i].symbol_type[0];
		}
	}
}
//检查并更新symbol table中的值
void check_scope_update(char *a,char *b,int sc)
{
	//printf("AAA\n");
	int i,j,k;
	int max=0;
	for(i=0;i<=n;i++)
	{
		if(!strcmp(a,st[i].symbol_name)   && sc>=st[i].scope)
		{
			if(st[i].scope>=max)
				max=st[i].scope;
		}
	}
	for(i=0;i<=n;i++)
	{
		if(!strcmp(a,st[i].symbol_name)   && max==st[i].scope)
		{
			float temp=atof(b);
			for(k=0;k<st[i].type_num;k++)
			{
				if(st[i].symbol_type[k]==258)
					st[i].f_value=(int)temp;
				else
					st[i].f_value=temp;
			}
		}
	}
}
/*void storevalue(char *a,char *b,int s_c)
{
	int i;
	for(i=0;i<=n;i++)
		if(!strcmp(a,st[i].symbol_name) && s_c==st[i].scope)
			st[i].f_value=atof(b);
}*/
//插入symbol table, 重复插入将更新类型序列
void insert(char *name, int type)
{
	int i;
	if(lookup(name))
	{
		strcpy(st[n].symbol_name,name);
		st[n].symbol_type[0]=type;
		st[n].type_num=1;
		st[n].symbol_no=n+1;
		st[n].parameter_num = 0;
		n++;
	}
	else
	{
		for(i=0;i<n;i++)
		{
			if(!strcmp(name,st[i].symbol_name))
			{
				st[i].symbol_type[st[i].type_num]=type;
				st[i].type_num++;
				break;
			}
		}
	}
	return;
}
//插入参数，适用与函数
void insert_parameter(char *name,int type)
{
 	int i;
 	for(i=0;i<n;i++)
 	{
  		if(!strcmp(name,st[i].symbol_name))
  		{

   			st[i].parameter_type[st[i].parameter_num]=type;
			st[i].parameter_num++;
   			break;
  		}
 	}
}
//插入索引数, 适用于数组
void insert_index(char *name,int ind)
{
 	int i;
 	for(i=0;i<n;i++)
 	{
  		if(!strcmp(name,st[i].symbol_name) && st[i].symbol_type[0]==273)//类型为Array
  		{
   			st[i].index = ind;
  		}
	}
}
//插入type, 适用于数组
void insert_by_scope(char *name, int type, int s_c)
{
 	int i;
	for(i=0;i<n;i++)
 	{
  		if(!strcmp(name,st[i].symbol_name) && st[i].scope==s_c)
  		{

   			st[i].symbol_type[st[i].type_num]=type;
			st[i].type_num++;
  		}
 	}
}

/*int checkp(char *name,int flist,int c)
{
 	int i,j;
 	for(i=0;i<n;i++)
 	{
  		if(!strcmp(name,st[i].symbol_name))
  		{
    			if(st[i].parameter_type[c]!=flist)
    			return 1;
  		}
 	}
 	return 0;
}*/

//检查参数，需要传入函数名，参数数量与参数类型序列
int check_parameter(char* name, int param_num, int* type_list)
{
	int i, j;
	for (i=0; i < n; i++)
	{
		if(!strcmp(name, st[i].symbol_name))
		{
			if(param_num != st[i].parameter_num) return 1;
			else
			{
				for(j = 0; j < st[i].parameter_num; j++)
				{
					if(st[i].parameter_type[j] != type_list[j])
						return 1;
				}
			}
		}
	}
	return 0;
}

void insert_dup(char *name, int type, int s_c)
{
	strcpy(st[n].symbol_name,name);
	st[n].type_num=1;
	st[n].symbol_type[0]=type;
	st[n].symbol_no=n+1;
	st[n].scope=s_c;
	n++;
	return;
}

