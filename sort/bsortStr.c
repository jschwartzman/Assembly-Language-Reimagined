///////////////////////////////////////////////////////////////
// bsortStr.c - bubblesort an array of strings
// John Schwartzman, Forte Systems, Inc.
// Tue Jan 21 03:54:54 PM EST 2025
///////////////////////////////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <stdlib.h>

char* array[] = {"Fred Flintstone", "Barney Rubble", "Wilma Flintstone",
                 "Betty Rubble", "Dino the Dinosaur", 
                 "Fido the Dogasauraus", "Rasputin the Mystin",
                 "Jack the Giant Killer", "Homer the Odyssey",
                 "Warner the Brother #2", "Warner the Brother #1" };
            
int nArrayCount = sizeof(array) / sizeof(array[0]);

void swap(int i, int j)
{
    char* pTemp = array[i];
    array[i] = array[j];
    array[j] = pTemp;
}

void bsort(void)
{
    bool bSwapped;

    do
    {
        for (int j = 0; j < nArrayCount - 1; ++j)
        {
            bSwapped = false;
            for (int i = j + 1; i < nArrayCount; ++i)    // i goes from 1 to 3
            {
                if (strcasecmp(array[i], array[j]) < 0)
                {
                    swap(i, j);
                    bSwapped = true;
                }
            }
        }
    }
    while (bSwapped);
}

int main(void) 
{   
    char searchStr[64];
    char* searchStrFmt = "%[^\n]";

    for (int i = 0; i < nArrayCount; i++)
    {
        printf("a[%d] = %s\n", i, array[i]);
    }

    printf("\n");
    bsort();

    for (int i = 0; i < nArrayCount; i++)
    {
        printf("a[%d] = %s\n", i, array[i]);
    }

    // printf("Enter the string for which you want to search: ");
    // fgets(searchStr, 64, stdin);
    // printf("%s\n", searchStr);
    return EXIT_SUCCESS;
}
