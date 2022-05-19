#include <stdio.h>
int fac(int n)
{
	if(n == 1)
	{
		return 1;
	}
	int temp = n;
	int x = temp - 1;
	int f = 0;
	f = fac(x);
	int res = temp * f;
	return res;
}
void main()
{
	int n = 5;
	int res = 0;
	res = fac(n);
	println(res);
	return;
}
