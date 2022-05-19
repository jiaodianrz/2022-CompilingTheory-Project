#include <stdio.h>
int main()
{
	int a=5;
	int b=6;
	while(a<20)
	{
		b=b+1;
		a=a+1;
		if(a >= 15)
		{
			break;
		}
	}
	print("The answer is:");
	println(b);
	println(a);
	return 0;
}
