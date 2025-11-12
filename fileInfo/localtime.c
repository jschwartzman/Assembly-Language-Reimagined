// fileSize.c
// John Schwartzman, Forte Systems, Inc.
// 06/16/2024

#include <time.h>
#include <stdio.h>

struct tm *timePtr;
char *timeFmt = "%s\n";
char buf[256];
time_t theTime;

int main()
{
    time(&theTime);
    timePtr = localtime(&theTime);
    strftime(buf, 256, "%b %d %H:%M", timePtr);
    printf(timeFmt, buf);
    return 0;
}
