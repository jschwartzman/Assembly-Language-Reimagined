//============================================================================
// fi.c
// John Schwartzman, Forte Systems, Inc.
// 03/29/2024
// Linux x86_64
//============================================================================

#include <stdio.h>
#include <sys/stat.h>

int printFileInfo(const char* pFilePath)
{
    struct stat    st;

	// perform lstat on pFilePath and place result in st
	int	nResult = lstat(pFilePath, &st);

	if (nResult != 0)
		{
			return nResult;
		}

	printf("FilePath: %s\n", pFilePath);
	printf("uid: %d, gid: %d\n", st.st_uid, st.st_gid);
	printf("File Size: %ld", st.st_size);
	return 0;
}

int main()
{
	const char* pFilePath = "/home/js/Development/asm_x86_64/userAsm/fi.c";
    return printFileInfo(pFilePath);
}