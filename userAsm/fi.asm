;============================================================================
; fi.asm
; John Schwartzman, Forte Systems, Inc.
; 03/31/2024
; Linux x86_64
;============================================================================
%include	"macro.inc"

global	    main
global		printFileInfo

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
%define	S_IXGRP		0010	; Execute by groupF
%define	S_IROTH		0004	; Read by others
%define	S_IWOTH		0002	; Write by others
%define	S_IXOTH		0001	; Execute by others

%define st			0
%define	st_dev		0		; structure st field sizes
%define st_inod		4
%define st_mode	   12
%define	st_nlink   16
%define st_uid	   24
%define	st_gid	   28
%define st_rdev	   32
%define	st_size	   40
%define st_blksize 48
%define st_blocks  56
%define st_atime   64
%define st_mtime   72
%define st_ctime   80

%define	NUM_VAR		4

;================== DEFINE LOCAL VARIABLES for printFileInfo =================
%define		filePath	qword [rsp + VAR_SIZE * (NUM_VAR - 4))]	; rsp +  0
%define		st	 		qword [rsp + VAR_SIZE * (NUM_VAR - 3)]	; rsp +  8
%define		pw	 		qword [rsp + VAR_SIZE * (NUM_VAR - 2)]	; rsp + 16
%define		gr			dword [rsp + VAR_SIZE * (NUM_VAR - 1)]	; rsp + 24

;============================== CODE SECTION ================================
section	.text

;============================================================================
printFileInfo:

	prologue NUM_VAR

	mov		filePath, rdi			; populate filePath
	lea		esi, st
	lstat							; fill st structure for this file
	jnz		.err1					; error - return with rax = -1

	lea		edi, [filePathFmt];
	lea		rsi, filePath
	print

	lea		rdi, [uidgidFmt]
	mov		esi, st + st_uid
	mov		edx, st + st_gid	
	print

	lea		rdi, [fileSizeFmt]
	mov		esi, st + st_size
	print
	jmp		.fin

.err1:
		leave
		ret

.fin:
	zero    eax                     ; EXIT_SUCCESS
	leave
	ret

;============================================================================
main:
	prologue 2
	lea     rdi, [pFilePath]
	call	printFileInfo

.fin:
	epilogue

;============================================================================

section		.bss

	; struc	st						; structure declaration
	; 	st_dev		resw	1
	; 	st_inod		resq	1
	; 	st_mode		resd 	1
	; 	align 4
	; 	st_nlink	resq 	1
	; 	st_uid		resd	1
	; 	st_gid		resd	1
	; 	st_rdev		resq	1
	; 	st_size		resq	1
	; 	st_blksize	resq	1
	; 	st_blocks 	resq	1
	; 	st_atime	resq	1
	; 	st_mtime	resq	1
	; 	st_ctime	resq	1
	; endstruc

	; struc	pw						; structure declarration
	; 	pw_name		resq	1
	; 	pw_passwd	resq	1
	; 	pw_uid		resd	1
	; 	pw_gid		resd	1
	; 	pw_gecos	resq	1
	; 	pw_dir		resq	1
	; 	pw_shell	resq	1
	; endstruc

	; struc	gr						; structure declaration
	; 	gr_name		resq	1
	; 	gr_passwd	resq	1
	; 	gr_gid		resd	1
	; 	gr_mem		resb  100
	; endstruc

section     .data
fileSizeFmt	db		"File Size: %d", LF, EOL
filePathFmt	db		"File Path: %s", LF, EOL
pFilePath	db		"/home/js/Development/asm_x86_64/userAsm/fi", EOL
uidgidFmt	db		"uid: %d gid: %d", LF, EOL

;============================================================================
