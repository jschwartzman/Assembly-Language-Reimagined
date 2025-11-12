// fileSize.c
// John Schwartzman, Forte Systems, Inc.
// 02/26/2024

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

// #define DIM(x) (sizeof(x)/sizeof(*(x)))
#define DIM(x) (sizeof(x)/sizeof(x[0]))

// static const char     *sizes[]   = { "EiB", "PiB", "TiB", "GiB", "MiB", "KiB", "B" };
static const char* 		sizes[]   = { "E", "P", "T", "G", "M", "K" };
// static const uint64_t  exbibytes = 1024ULL * 1024ULL * 1024ULL *
// 								   1024ULL * 1024ULL * 1024ULL;
static const uint64_t  exbibytes = 1000ULL * 1000ULL * 1000ULL *
								   1000ULL * 1000ULL * 1000ULL + 1000ULL;
char result[20];

char* calculateSize(uint64_t size)
{
	if (size < 1000)
	{
		sprintf(result, "%ld", size);
		return result;
	}

	uint64_t  multiplier = exbibytes;

	// for (int i = 0; i < DIM(sizes); i++, multiplier /= 1024)
	for (int i = 0; i < DIM(sizes); i++, multiplier /= 1000)
	{   
		if (size < multiplier)
		{
			continue;
		}
		if (size % multiplier == 0)
		{
			// sprintf(result, "%" PRIu64 " %s", size / multiplier, sizes[i]);
			sprintf(result, "%" PRIu64 "%s", size / multiplier, sizes[i]);
		}
		else
		{
			// sprintf(result, "%.1f %s", (float) size / multiplier, sizes[i]);
			sprintf(result, "%.1f%s", (float) size / multiplier, sizes[i]);
		}
		return result;
	}
	
	strcpy(result, "0");
	return result;
}

#ifdef NEEDED

int main()
{
	uint64_t nFileSize[] = { 0, 10, 100, 999, 1121, 21000, 22007, 22107, 1250000, 135000000, 
							 123000000000, 1230000000000 };
	char*    pFileSize;

	for (int i = 0; i < 12; i++)
	{
		pFileSize = calculateSize(nFileSize[i]);
		printf("%s\n", pFileSize);
	}
	return EXIT_SUCCESS;
}

#endif