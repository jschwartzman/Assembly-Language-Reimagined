//============================================================================
// directory.c - retrieve ls info from the OS, sort & print it (ignores . and ..)
// John Schwartzman, Forte Systems, Inc.
// 03/10/2024
// Linux x86_64
//
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <dirent.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <stdint.h>
#include <pwd.h>
#include <grp.h>
#include <time.h>
#include <fcntl.h>

char* pFileSize = NULL;
const char* pCurrentDir = ".";
const char* pParentDir	= "..";

char* calculateSize(uint64_t size);		// forward declaration

void printFileType(const char* pFileName)
{
	struct stat* 	st = NULL;
    struct passwd*  pw = NULL;
    struct group*   gr = NULL;
	char 			filePerm[10];
	
	lstat(pFileName, st);
	unsigned int nType = st->st_mode & S_IFMT;

	pw = getpwuid(st->st_uid);
	gr = getgrgid(st->st_gid);

	if (nType == __S_IFREG)
		filePerm[0] = '-';
	else if (nType == __S_IFDIR)
		filePerm[0] = 'd';
	else if (nType == __S_IFLNK)
		filePerm[0] = 'l';
	else if (nType == __S_IFIFO)
		filePerm[0] = 'p';
	else if (nType == __S_IFSOCK)
		filePerm[0] = 's';
	else if (nType == __S_IFBLK)
		filePerm[0] = 'b';
	else if (nType == __S_IFCHR)
		filePerm[0] = 'c';

	if (st->st_mode & S_IRUSR)
		filePerm[1] = 'r';
	else
		filePerm[1] = '-';

	if (st->st_mode & S_IWUSR)
		filePerm[2] = 'w';
	else
		filePerm[2] = '-';

	if (st->st_mode & S_IXUSR)
		filePerm[3] = 'x';
	else
		filePerm[3] = '-';


	if (st->st_mode & S_IRGRP)
		filePerm[4] = 'r';
	else
		filePerm[4] = '-';

	if (st->st_mode & S_IWGRP)
		filePerm[5] = 'w';
	else
		filePerm[5] = '-';

	if (st->st_mode & S_IXGRP)
		filePerm[6] = 'x';
	else
		filePerm[6] = '-';


	if (st->st_mode & S_IROTH)
		filePerm[7] = 'r';
	else
		filePerm[7] = '-';

	if (st->st_mode & S_IWOTH)
		filePerm[8] = 'w';
	else
		filePerm[8] = '-';

	if (st->st_mode & S_IXOTH)
		filePerm[9] = 'x';
	else
		filePerm[9] = '-';
	
	for (int i = 0; i < 10; i++)
	{
		printf("%c", filePerm[i]);
	}

	// print num links and user/group info
	printf(" %ld %s %s ", st->st_nlink, pw->pw_name, gr->gr_name);

	// print file size
	printf("%5s", calculateSize(st->st_size));

	// print file time and date of last modification
	char pDateTime[40];
	struct tm* tmp = localtime(&st->st_mtime);
	strftime(pDateTime, 40, " %b %d %H:%M", tmp);
	printf("%s %s", pDateTime, pFileName);

	if (filePerm[0] == 'l')
	{
		char buffer[128];
		if (readlink(pFileName, buffer, 128) == -1)
		{
			perror("readlink");
			return;
		}

		printf(" -> %s*\n", buffer);	// print symbolic link
		return;
	}

	if (st->st_mode & __S_IEXEC)			// executable by owner
	{
		puts("*");
		return;
	}

	puts("");
	return;
}

int main(int argc, char* argv[])
{
    DIR*            dir;
    struct dirent*  dent = NULL;
	const char* 	pDir = 	argv[1];
	if (!(pDir = argv[1]))
	{
		pDir = pCurrentDir;
	}

    dir = opendir(pDir);
   
    if (dir != NULL)
    {
		if (chdir(pDir))
		{
			perror("chdir");
			return EXIT_FAILURE;
		}

		while ((dent = readdir(dir)) != NULL)
		{
			const char*	pFileName = dent->d_name;
			// ignore . and .. directories
			if (strcmp(pFileName, pCurrentDir) && strcmp(pFileName, pParentDir)) 
			{
				printFileType(pFileName);
			}
		}
	}
    closedir(dir);

    return EXIT_SUCCESS;
}