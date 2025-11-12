#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char* array[] =
{
	"Fred Flintstone",
	"Barney Rubble",
	"Wilma Flintstone",
	"Betty Rubble",
	"Dino the Dinosaur",
	"Fido the Dogasauraus",
	"Rasputin",
	"Jack the Giant",
	"Homer the Odyssey", 
	"Warner the Brother #2",
	"Warner the Brother #1"
};

int nArraySize = sizeof(array) / sizeof(array[0]);

void swap(int i, int j)
{
	char* pTemp = array[i];
	array[i] = array[j];
	array[j] = pTemp;
 }

int partition(int nLow, int nHigh)
{
	//choose the pivot
	char* pPivot = array[nHigh];
	//Index of smaller element and Indicate
	//the right position of pivot found so far
	int i = nLow - 1;
	int j;
	 
	for(j = nLow; j <= nHigh; j++)
	{
		//If current element is smaller than the pivot
		if (strcmp(array[j], pPivot) < 0)
		{
			//Increment index of smaller element
			i++;
			swap(i, j);
		}
	}
	swap(i + 1,nHigh);
	return i + 1;
}
 
void quickSort(int nLow,int nHigh)
{
	// when nLow is less than nHigh
	if(nLow < nHigh)
	{
		// nPivot is the partition return index of nPivot
		int nPivot = partition(nLow, nHigh);
		 
		//Recursion Call
		//smaller element than pivot goes left and
		//nHigher element goes right
		quickSort(nLow, nPivot - 1);
		quickSort(nPivot + 1, nHigh);
	}
}

int main(void)
{
	puts("\nInsertion Sorted Array:");
	for (int i = 0; i < nArraySize; i++)
	{
		printf("\t%s\n", array[i]);
	}

	quickSort(0, nArraySize - 1);
	
	puts("\nQuicksorted Array:");
	for (int i = 0; i < nArraySize; i++)
	{
		printf("\t%s\n", array[i]);
	}

	puts("");
	return EXIT_SUCCESS;
}
 