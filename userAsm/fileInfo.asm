;============================================================================
; fileInfo.asm
; John Schwartzman, Forte Systems, Inc.
; 03/30/2024
; Linux x86_64
;============================================================================
%include	"macro.inc"

global	    main
; global		printFileInfo

%define S_IFMT   00170000

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
	prologue 2

	lea		edi, [pFilePath]
	lea		esi, [st]
	lstat							; fill stat structure for this file
	jnz		.err1					; error - return with rax = -1

	lea		edi, [filePathFmt];
	lea		rsi, [pFilePath]
	print

	lea		rdi, [uidgidFmt]
	mov		rsi, qword [st + st_uid]
	mov		rdx, qword [st + st_gid]
	print

	mov		edi, dword [st + st_uid]	; get uid from st
	getpwuid
	mov		[pw], eax

	mov		edi, dword [st + st_gid]	; get gid from st
	getgrgid
	mov		[gr], eax
	
	cmp		eax, S_IFREG
	mov		byte [filePerm + 0], '-'	; regular
	je		.gotFileType

	cmp	eax, S_IFDIR					; directory
	mov		byte [filePerm + 0], 'd'
	je		.gotFileType
	
	test	eax, S_IFLNK				; symbolic link
	mov		byte [filePerm + 0], 'l'
	jnz		.gotFileType

	cmp		eax, S_IFSOCK
	mov		byte [filePerm + 0], 's'	; socket
	je		.gotFileType

	test	eax, S_IFBLK
	mov		byte [filePerm + 0], 'b'	; byte
	jnz		.gotFileType

	cmp		eax, S_IFCHR
	mov		byte [filePerm + 0], 'c'	; character
	jne		.gotFileType

	cmp		eax, S_IFIFO				; FIFO (pipe)
	mov		byte [filePerm + 0], 'p'
	je		.gotFileType

	mov		byte [filePerm + 0], '?'

.gotFileType:
	mov		eax, dword [st + st_mode]
	test 	eax, S_IRUSR				; owner read perm
	mov		byte [filePerm + 1], 'r'
	jnz		.gotUserRead

.gotUserRead:
	test	rax, S_IWUSR				; owner write perm
	mov		byte [filePerm + 2], 'w'
	jnz		.gotUserWrite

.gotUserWrite:
	test	rax, S_IXUSR				; owner execute perm
	mov		byte [filePerm + 3], 'x'
	jnz		.gotUserExecute				

.gotUserExecute:
	test	rax, S_IRGRP				; group read perm
	mov		byte [filePerm + 4], 'r'
	jnz		.gotGroupRead

.gotGroupRead:
	test	rax, S_IWGRP				; group write perm
	mov		byte [filePerm + 4], 'w'
	jnz		.gotGroupWrite

.gotGroupWrite:
	test	rax, S_IXGRP				; group execute perm
	mov		byte [filePerm + 5], 'x'
	jnz		.gotGroupExecute

.gotGroupExecute:
	test	rax, S_IROTH				; other read perm
	mov		byte [filePerm + 6], 'r'
	jnz		.gotOtherRead

.gotOtherRead:
	test	rax, S_IWOTH				; other write perm
	mov		byte [filePerm + 7], 'w'
	jnz		.gotOtherWrite

.gotOtherWrite:
	test	rax, S_IXOTH
	mov		byte [filePerm + 8], 'x'
	jnz		.gotOtherExecute

.gotOtherExecute:
	print	[nameFmt], [pFileName]
	lea		rdi, [strucSizeFmt]
	mov		rsi, [st + st_size]
	print
	print	[uidFmt], [pw + pw_name]
	print	[gidFmt], [gr + gr_name]
	print	[linksFmt], [st + st_nlink]
	print	[permFmt], [filePerm]
	print	[sizeFmt], [st + st_size]

	lea		rdi, [infoFmtSt]
	mov		rsi, [st + st_dev]
	mov		rdx, [st + st_ino]
	mov		rcx, [st + st_mode]
	mov		r8, [st + st_nlink]
	mov		r9,  [st + st_uid]
	print

	lea		rdi, [infoFmtPw]
	mov		rsi, pw_name
	mov		rdx, pw_passwd
	mov		rcx, pw_uid
	mov		r8, pw_gid
	mov		r9, pw_gecos
	print

	lea		rdi, [infoFmtGr]
	mov		rsi, gr_name
	mov		rdx, gr_passwd
	mov		rcx, gr_gid
	mov		rcx, gr_mem
	print

	lea		rdi, [stPtrFmt]
	lea		rsi, [st + st_dev]
	lea		rdx, [st + st_ino]
	lea		rcx, [st + st_mode]
	lea		r8,  [st + st_nlink]
	lea		r9,  [st + st_uid]
	print

	lea		rdi, [strPtrFmt2]
	lea		rsi, [st + st_gid]
	lea		rdx, [st + st_size]
	lea		rcx, [st + st_blksize]
	print

	lea		rdi, [contsFmt]
	mov		rsi, [st + st_dev]
	mov		rsi, [st + st_ino]
	mov		rdx, [st + st_mode]
	mov		rcx, [st + st_nlink]
	mov		r8,	 [st + st_uid]
	print

	lea		rdi, [contsFmt2]
	mov		rsi, [st + st_gid]
	mov		rdx, [st + st_size]
	mov		rcx, [st + st_blksize]
	print

	zero	eax						; set EXIT_SUCCESS
	jmp		.fin

.err1:
	perror [lstatName]
.err2:
	mov		eax, EXIT_FAILURE

.fin:
	epilogue

;============================================================================
main:
	prologue
	call	printFileInfo

.fin:
	epilogue

;============================================================================

section		.bss
	struc	stat				; structure declaration
		st_dev		resw	1
		st_ino		resq	1
		st_mode		resd 	1
		st_nlink	resq 	1
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
		pw_passwd	resq	1
		pw_uid		resd	1
		pw_gid:		resd	1
		pw_gecos	resq	1
		pw_dir		resq	1
		pw_shell	resq	1
	endstruc

	struc	grp						; structure declaration
		gr_name		resq	1
		gr_passwd	resq	1
		gr_gid		resd	1
		gr_mem		resb  100
	endstruc


section .data
lstatName		db		"lstat returned", EOL
nameFmt		    db      "File: %s", LF, EOL
uidFmt       	db      "uid: %s", LF, EOL
gidFmt       	db      "gid: %s", LF, EOL
strucSizeFmt	db		"st_size: %ld", LF, EOL
uidgidFmt		db		"uid: %ji gid: %ji", LF, EOL
linksFmt     	db      "hard links: %ld", LF, EOL
permFmt    		db		"Permissions: %s", LF, EOL
sizeFmt			db		"size: %ld", LF, EOL
infoFmtSt		db		"st: %w, %ld, %d, %ld, %d", LF, EOL
infoFmtPw		db		"pw: %ld, %ld, %ld, %ld, %ld", LF, EOL
infoFmtGr		db		"gr: %ld, %ld, %ld, %ld", LF, EOL
stPtrFmt		db		"st: %p, %p, %p, %p, %p, ", EOL
strPtrFmt2		db		"%p, %p, %p", LF, EOL
contsFmt		db		"st: %ld, %ld, %d, %ld, %d, ", EOL
contsFmt2		db		"%ld, %ld, %ld", LF, EOL

section		.data
filePerm	db		'-', '-', '-', '-', '-', '-', '-', '-', '-', '-', EOL	; reserve 10 char file perm
userIdStr	db		32, EOL
groupIdStr	db		32, EOL
fileSize	db		 5, EOL
fileTime	db		12, EOL
filePathFmt	db		"File Path: %s", LF, EOL
pFilePath	db		"/home/js/Development/asm_x86_64/userAsm/fileInfo", EOL
pFileName	db		"fileInfo", EOL

st  	istruc	stat    		; structure allocation
		iend
pw		istruc	pwrd			; structure allocation
		iend
gr		istruc	grp				; structure allocation
		iend


