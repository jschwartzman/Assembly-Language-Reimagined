// fileSize.c
// John Schwartzman, Forte Systems, Inc.
// 06/06/2024

// Compile with: gcc -O0 -g -D NEEDED fileSize.c -o fileSize

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

extern int main();
extern void printFileSize(unsigned long long nFileSize);

static const char				sizes[]   = { 'E', 'P', 'T', 'G', 'M', 'K' };
static const unsigned long long range[] = 
{
	1000ULL * 1000ULL * 1000ULL * 1000ULL * 1000ULL * 1000ULL + 1000ULL,
	1000ULL * 1000ULL * 1000ULL * 1000ULL * 1000ULL * 1000ULL,
	1000ULL * 1000ULL * 1000ULL * 1000ULL * 1000ULL,
	1000ULL * 1000ULL * 1000ULL * 1000ULL,
	1000ULL * 1000ULL * 1000ULL,
	1000ULL * 1000ULL,
	1000ULL
};

void printFileSize(unsigned long long nSize)
{
	if (nSize < 1000)
	{
		printf("%lld\n", nSize);
		return;
	}

	for (int i = 0; i < 7; i++)
	{   
		const unsigned long long  nMultiplier = range[i];
		if (nSize < nMultiplier)
		{
			continue;
		}

		unsigned long long nTemp = nSize % nMultiplier;
		if (nTemp == 0)
		{
			nTemp = nSize / nMultiplier;
			printf("%lld.0%c\n", nTemp, sizes[i - 1]);
			return;
		}
		else
		{
			float nTemp = (float)nSize / nMultiplier;
			printf("%.1f%c\n", nTemp, sizes[i - 1]);
			return;
		}
	}
	
}

#ifdef NEEDED	//===========================================================

int main()
{
	unsigned long long nFileSize[] = { 0, 10, 100, 999, 
									   1000, 1121, 21000, 22007, 
							 		   22107, 1250000, 135000000, 
							 		   123000000000, 1230000000000 };

	for (int i = 0; i <= 12; ++i)
	{
		printFileSize(nFileSize[i]);
	}
	return EXIT_SUCCESS;
}

#endif	// NEEDED ===========================================================