// fileType.c
// John Schwartzman, Forte Systems, Inc.
// 03/08/2024

#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <stdint.h>
#include <pwd.h>
#include <grp.h>
#include <time.h>
#include <unistd.h>
#include <string.h>

// global variables
char fileName[64];
char 			filePath[128];
char* 			pFileType;
char			filePerm[10];
struct stat		st;
struct passwd	pw;
struct group	gr;

void setFilePath(const char* pFilePath)
{
	strcpy(filePath, pFilePath);
}

void setFileName(const char* pFileName)
{
	strcpy(fileName, pFileName);
}

char* calculateSize(uint64_t size);


void printFileInfo(const char* pFilePath)
{
	setFilePath(pFilePath);
	lstat(pFilePath, &st);
	unsigned int nType = st.st_mode;
	nType &= __S_IFMT;

	pw = *getpwuid(st.st_uid);
	gr = *getgrgid(st.st_gid);

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

	if (st.st_mode & S_IRUSR)
		filePerm[1] = 'r';
	else
		filePerm[1] = '-';

	if (st.st_mode & S_IWUSR)
		filePerm[2] = 'w';
	else
		filePerm[2] = '-';

	if (st.st_mode & S_IXUSR)
		filePerm[3] = 'x';
	else
		filePerm[3] = '-';


	if (st.st_mode & S_IRGRP)
		filePerm[4] = 'r';
	else
		filePerm[4] = '-';

	if (st.st_mode & S_IWGRP)
		filePerm[5] = 'w';
	else
		filePerm[5] = '-';

	if (st.st_mode & S_IXGRP)
		filePerm[6] = 'x';
	else
		filePerm[6] = '-';


	if (st.st_mode & S_IROTH)
		filePerm[7] = 'r';
	else
		filePerm[7] = '-';

	if (st.st_mode & S_IWOTH)
		filePerm[8] = 'w';
	else
		filePerm[8] = '-';

	if (st.st_mode & S_IXOTH)
		filePerm[9] = 'x';
	else
		filePerm[9] = '-';
	
	for (int i = 0; i < 10; i++)
	{
		printf("%c", filePerm[i]);
	}

	// print num links and user/group info
	printf(" %d %s %s ", st.st_nlink, pw.pw_name, gr.gr_name);

	print file size
	printf("%5s", calculateSize(st.st_size));

	// print file time and date of last modification
	char pDateTime[40];
	struct tm* tmp = localtime(&st.st_mtime);
	strftime(pDateTime, 40, " %b %d %H:%M", tmp);
	printf("%s %s", pDateTime, fileName);

	if (filePerm[0] == 'l')				// if symlink then readlink
	{
		char buffer[128];
		if (readlink(pFilePath, buffer, 128) == -1)
		{
			perror("readlink");
			return;
		}

		printf(" -> %s*\n", buffer);	// print symbolic link
		return;
    }
	else if (st.st_mode & S_IXUSR)
	{
		puts("*");
		return;
	}

    puts("");
	return;
}