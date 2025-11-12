//============================================================================
// user.c - retrieve ls info from the OS, sort & print it (ignores . and ..)
// John Schwartzman, Forte Systems, Inc.
// 01/21/2024
// Linux x86_64
//
#include <sys/types.h>
#include <pwd.h>
#include <grp.h>
#include <stdio.h>
#include <unistd.h>

int main()
{
    uid_t           uid;
    gid_t           gid;
    struct passwd*  pw;
    struct group*   gr;
    uid = getuid();
    gid = getgid();

    printf("User IDs: uid = %d, gid = %d\n", uid, gid);

    pw = getpwuid(uid);
    printf("UID passwd entry:\n name = %s, uid = %d, gid = %d, home = %s, shell = %s\n", 
            pw->pw_name, pw->pw_uid, pw->pw_gid, pw->pw_dir, pw->pw_shell);

    gr = getgrgid(gid);
    printf("GID group entry:\n name = %s\n", gr->gr_name);

    pw = getpwnam("root");
    printf("root passwd entry:\n");
    printf("name = %s, uid = %d, gid = %d, home = %s, shell = %s\n",
            pw->pw_name, pw->pw_uid, pw->pw_gid, pw->pw_dir, pw->pw_shell);
    return 0;
}