;============================================================================printFileInfo
; fileType.asm
; John Schwartzman, Forte Systems, Inc.
; 03/20/2024
; Linux x86_64
;
;============================ CONSTANT DEFINITIONS ==========================
NUM_VAR			equ	   4		; for printFileInfo - round up to even number
ARG_SIZE		equ	   8		; size of argv vector
;============================================================================

%include	"macro.inc"

global	main
global		printFileInfo
global		filePath, fileName

%define S_IFMT  00170000

%define S_IFSOCK 0140000	; socket - from <sys/stat.h>
%define S_IFLNK  0120000	; symbolic link
%define S_IFREG  0100000	; regular file
%define S_IFBLK  0060000	; block device
%define S_IFDIR  0040000	; directory
%define S_IFCHR  0020000	; character device
%define S_IFIFO  0010000	; fifo (pipe)

%define	S_IRUSR		0400	; Read by owner
%define	S_IWUSR		0200	; Write by owner
%define	S_IXUSR		0100	; Execute by owner
%define	S_IRGRP		0040	; Read by group
%define	S_IWGRP		0020	; Write by group
%define	S_IXGRP		0010	; Execute by group
%define	S_IROTH		0004	; Read by others
%define	S_IWOTH		0002	; Write by others
%define	S_IXOTH		0001	; Execute by others

;============================== CODE SECTION ================================
section	.text

;============================================================================
printFileInfo:
	prologue

	lea		rdi, [filePath]
	lea		esi, [stat]
	lstat							; fill stat structure for this file

	cmp		eax, -1
	je		.err					; error - return with rax = -1

	; ; try saving rax into stat structure
	; mov		[stat], rax

	mov		edi, dword [stat + st_uid]	; get uid from stat
	getpwuid
	mov		[pw], eax
	
	lea		edi, dword [pw + pw_uid]	; get uidName from pw
	
	mov		edi, dword [stat + st_gid]	; get gid from stat
	getgrgid
	mov		[gr], eax
	lea		edi, dword [gr + gr_gid]	; get gidName from gr

	lea		eax, dword [stat + st_mode]	; get file type
	and		eax, S_IFMT

	test	eax, S_IFREG
	mov		byte [filePerm + 0], '-'	; regular
	jnz		.gotFileType

	test	eax, S_IFDIR				; directory
	mov		byte [filePerm + 0], 'd'
	jnz		.gotFileType
	
	test	eax, S_IFLNK				; symbolic link
	mov		byte [filePerm + 0], 'l'
	jnz		.gotFileType

	test	eax, S_IFSOCK
	mov		byte [filePerm + 0], 's'	; socket
	jnz		.gotFileType

	test	eax, S_IFBLK
	mov		byte [filePerm + 0], 'b'	; byte
	jnz		.gotFileType

	test	eax, S_IFCHR
	mov		byte [filePerm + 0], 'c'	; character
	jnz		.gotFileType

	test	eax, S_IFIFO				; FIFO (pipe)
	mov		byte [filePerm +0], 'p'
	jnz		.gotFileType

	mov		byte [filePerm + 0], '?'

.gotFileType:
	mov		eax, dword [stat + st_mode]
	test 	eax, S_IRUSR				; owner read perm
	mov		byte [filePerm + 1], 'r'
	jnz		.gotUserRead
	mov		byte [filePerm + 1], '-'

.gotUserRead:
	test	rax, S_IWUSR				; owner write perm
	mov		byte [filePerm + 2], 'w'
	jnz		.gotUserWrite
	mov		byte [filePerm + 2], '-'

.gotUserWrite:
	test	rax, S_IXUSR				; owner execute perm
	mov		byte [filePerm + 3], 'x'
	jnz		.gotUserExecute				
	mov		byte [filePerm + 3],   '-'

.gotUserExecute:
	test	rax, S_IRGRP				; group read perm
	mov		byte [filePerm + 4], 'r'
	jnz		.gotGroupRead
	mov		byte [filePerm + 4], '-'

.gotGroupRead:
	test	rax, S_IWGRP				; group write perm
	mov		byte [filePerm + 4], 'w'
	jnz		.gotGroupWrite
	mov		byte [filePerm + 4], '-'

.gotGroupWrite:
	test	rax, S_IXGRP				; group execute perm
	mov		byte [filePerm + 5], 'x'
	jnz		.gotGroupExecute
	mov		byte [filePerm + 5], '-'

.gotGroupExecute:
	test	rax, S_IROTH				; other read perm
	mov		byte [filePerm + 6], 'r'
	jnz		.gotOtherRead
	mov		byte [filePerm + 6], '-'

.gotOtherRead:
	test	rax, S_IWOTH				; other write perm
	mov		byte [filePerm + 7], 'w'
	jnz		.gotOtherWrite
	mov		byte [filePerm + 7], '-'

.gotOtherWrite:
	test	rax, S_IXOTH
	mov		byte [filePerm + 8], 'x'
	jnz		.gotOtherExecute
	mov		byte [filePerm + 8], '-'

.gotOtherExecute:
	; test	rax, S_IXOTH
	; mov		byte [filePerm + 9], 'x'
	; jnz		.gotPermissions
	; mov		byte [filePerm + 9], '-'

.gotPermissions:
	mov		byte [filePerm + 10], 0	; set delimiter

	lea		edi, [prtFmt]			; print format
	mov		esi, [filePerm]			; file permissions
	mov		edx, [stat + st_nlink]	; hard links

	lea		ecx, [userIdStr]		; user id string
	lea		r8d, [groupIdStr]		; group id string

	print							; display permissions, hard links, user id name, grout id name

	zero	rax						; set EXIT_SUCCESS
	jmp		.fin

.err:
	perror [lstatName]
	mov		rax, EXIT_FAILURE

.fin:
	epilogue

;============================================================================

%ifdef NEEDED

main:
	prologue
	lea		rdi, [fileName]
	lea		rsi, [st_status]
	call	printFileInfo
	lea		rdi, [prtFmt]
	lea		rsi, [rax]
	print	[ptrFmt], [rax]
	print	[prtNameFmt], [fileName]

.fin:
	epilogue

%endif

;============================================================================

section		.rodata
	struc	file_status				; structure declaration
		st_dev		resq	1
		st_ino		resq	1
		st_mode		resd 	1
		st_nlink	resd 	1
		st_uid		resd	1
		st_gid		resd	1
		st_rdev		resq	1
		st_size		resq	1
		st_blksize	resq	1
		st_blocks 	resq	1
		st_atime	resq	1
		st_mtime	resq	1
		st_ctime	resq	1
	endstruc

	struc	pwrd					; structure declarration
		pw_name		resq	1
		pw_uid		resq	1
		pw_gid		resq	1
		pw_dir		resq	1
		pw_shell	resq	1
	endstruc

	struc	grp						; structure declaration
		gr_name		resq	1
		gr_gid		resq	1
		gr_mem		resq	1
	endstruc

lstatName	db		"lstat returned", EOL
prtFmt		db		"%s %1d %s %s ", EOL	; filePerm userId groupId nIdx
; prtFmt		db		"%s ", EOL
prtNameFmt	db		"%s", LF, EOL

section		.data
filePerm	db		11, EOL		; reserve 10 characters for file permissions
userIdStr	db		32, EOL
groupIdStr	db		32, EOL
fileSize	db		 5, EOL
fileTime	db		12, EOL
fileName	db		64, EOL
filePath	db	   128, EOL

stat	istruc	file_status		; structure allocation
		iend
pw		istruc	pwrd			; structure allocation
		iend
gr		istruc	grp				; structure allocation
		iend


