// environment.c
// John Schwartzman, Forte Systems, Inc.
// 05/29/2023

#include <time.h>       // declaration of time; definition of time_t

int printenv(const char* dateTimeStr);   // declaration of asm function

int main(void)
{
    time_t  now;
    char*   dateTimeStr;

    time(&now);
    dateTimeStr = ctime(&now);
    return printenv(dateTimeStr);       // call printenv function with strTime arg
}
   