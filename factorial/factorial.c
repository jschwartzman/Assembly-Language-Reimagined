// factorial.c
// John Schwartzman, Forte Systems, Inc.
// 05/17/2023

#define MAX_INT 20

#include<stdio.h>   // for printf and scanf

#if defined(__COMMA__)

	int commaSeparate(long n, char* buffer);     // declaration of asm function

#endif //__COMMA__ 


// recursive function to compute factorial of n
long factorial(int n)
{
	if (n == 1) // base case
	{
		return 1;
	}
	else
	{
		return (n * factorial(n - 1));
	} 
}  
	
int main()  
{  
	int 	nRetVal = 0;
	int     n;  
	long    fact;

	do  
	{
			printf("\nEnter a positive integer less than or equal to %d: ", MAX_INT);  
			scanf("%d", &n); 
		}
	while (n < 1 || n > MAX_INT);
	
	fact = factorial(n);  
	printf("%d! = %ld\n", n, fact);
  
	#if defined(__COMMA__)

		char	buffer[32];
		nRetVal = commaSeparate(fact, buffer);
		printf("%d! = %s\n\n", n, buffer);

	#endif  //__COMMA__

	return nRetVal;  
}  