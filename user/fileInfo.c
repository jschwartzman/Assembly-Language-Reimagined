#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <pwd.h>
#include <grp.h>

struct stat     st;
struct passwd*	pw;
struct group*	gr;

const char*     pFileName = "goldfish";
const char*     pFilePath = "/home/js/Development/asm_x86_64/user/files/goldfish";
char			filePerm[11];

void printFileInfo()
{
    if (lstat(pFilePath, &st) == 0)
		return;

	pw = getpwuid(st.st_uid);
	gr = getgrgid(st.st_gid);

	unsigned int nType = st.st_mode & __S_IFMT;

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
	
    filePerm[10] = 0;

    printf("File: %s\n", pFileName); 
    printf("uid str: %s\n", pw->pw_name);
    printf("gid str: %s\n", gr->gr_name);
    printf("hard links: %ld\n", st.st_nlink);
    printf("Permissions: %s\n", filePerm);
    printf("size: %ld\n", st.st_size);
	printf("mode: %d]n", st.st_mode);
}

int main()
{
    printFileInfo();
    return 0;
}