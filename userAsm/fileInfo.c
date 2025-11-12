//============================================================================
// fileInfo.c
// John Schwartzman, Forte Systems, Inc.
// 03/28/2024
// Linux x86_64
//============================================================================

#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>
// #include <asm/stat.h>
#include <pwd.h>
#include <grp.h>

struct stat     st;
struct passwd*	pw;
struct group*	gr;

const char*     pFilePath = "fi.asm";
char			filePerm[] = { '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', 0};

// printFileInfo
int printFileInfo()
{
	// perform lstat on pFilePath and place result in st
	int	nResult = lstat(pFilePath, &st);

	if (nResult != 0)
		{
			return nResult;
		}

	printf("uid: %d, gid: %d\n", st.st_uid, st.st_gid);

	// invoke getpwuid
	pw = getpwuid(st.st_uid);

	// invoke getgrgid
	gr = getgrgid(st.st_gid);

	printf("uid: %s, gid: %s\n", pw->pw_name, gr->gr_name);

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

	if (st.st_mode & S_IWUSR)
		filePerm[2] = 'w';

	if (st.st_mode & S_IXUSR)
		filePerm[3] = 'x';


	if (st.st_mode & S_IRGRP)
		filePerm[4] = 'r';

	if (st.st_mode & S_IWGRP)
		filePerm[5] = 'w';

	if (st.st_mode & S_IXGRP)
		filePerm[6] = 'x';


	if (st.st_mode & S_IROTH)
		filePerm[7] = 'r';

	if (st.st_mode & S_IWOTH)
		filePerm[8] = 'w';

	if (st.st_mode & S_IXOTH)
		filePerm[9] = 'x';

	// print info collected by printFileInfo	
    printf("File: %s\n", pFilePath); 
    printf("hard links: %ld\n", st.st_nlink);
    printf("Permissions: %s\n", filePerm);
    printf("File size: %ld\n", st.st_size);

	printf("st_dev:     %d\n", sizeof(dev_t));
	printf("st_ino:     %d\n", sizeof(ino_t));
	printf("st_mode:    %d\n", sizeof(mode_t));
	printf("st_nlink:   %d\n", sizeof(nlink_t));
	printf("st_uid:     %d\n", sizeof(uid_t));
	printf("st_gid:     %d\n", sizeof(gid_t));
	printf("st_rdev:    %d\n", sizeof(dev_t));
	printf("st_size:    %d\n", sizeof(off_t));
	printf("st_blksize: %d\n", sizeof(__blksize_t));
	printf("st_blocks:  %d\n", sizeof(blkcnt_t));
	printf("st_atime:   %d\n", sizeof(time_t));
	printf("st_mtime:   %d\n", sizeof(time_t));
	printf("st_cdtime:  %d\n", sizeof(time_t));

	return nResult;
}

int main()
{
    return printFileInfo();
}