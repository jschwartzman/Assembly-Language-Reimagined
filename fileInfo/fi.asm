;============================================================================
; fi.asm
; John Schwartzman, Forte Systems, Inc.
; 06/16/2024
; Linux x86_64
;============================================================================
%include	"macro.inc"

global	    main
;global		printFileInfo
extern		printFileSize
extern		printFileTime

global		mtime

%define PETABYTE	DIVISOR * DIVISOR * DIVISOR * DIVISOR * DIVISOR 
%define TERABYTE	DIVISOR * DIVISOR * DIVISOR * DIVISOR 
%define GIGABYTE	DIVISOR * DIVISOR * DIVISOR 
%define MEGABYTE	DIVISOR * DIVISOR 
%define KILOBYTE	DIVISOR 
%define BYTE		0

%define S_IFMT   0170000q	; q is necessary to indicate octal values

%define S_IFSOCK 0140000q	; socket - from <sys/stat.h>
%define S_IFLNK  0120000q	; hard link
%define S_IFREG  0100000q	; regular file
%define S_IFBLK  0060000q	; block device
%define S_IFDIR  0040000q	; directory
%define S_IFCHR  0020000q	; character device
%define S_IFIFO  0010000q	; fifo (pipe)

%define	S_IRUSR		0400q	; Read by owner
%define	S_IWUSR		0200q	; Write by owner
%define	S_IXUSR		0100q	; Execute by owner
%define	S_IRGRP		0040q	; Read by group
%define	S_IWGRP		0020q	; Write by group
%define	S_IXGRP		0010q	; Execute by group
%define	S_IROTH		0004q	; Read by others
%define	S_IWOTH		0002q	; Write by others
%define	S_IXOTH		0001q	; Execute by others

;============================== CODE SECTION ================================
section	.text

printFileInfo:
	prologue

	lea		rdi, [pFilePath]
	lea		rsi, [stat64]
	lstat							; fill stat structure for this file
	cmp		rax, -1
	je		.err1					; error - return with rax = -1

	lea		eax, dword [stat64]
	add		eax, st_uid				; get offset of uid
	mov		esi, dword [eax]

	lea		rsi, qword [stat64]		; get mode
	add		rsi, st_mode
	mov		esi, [rsi]
	mov		[nMode], esi

	lea		rdi, [stat64]			; get uid
	add		rdi, st_uid
	mov		rdi, [rdi]
	getpwuid						; get struc password
	mov		[pw], rax

	lea		rdi, [pw]				; get gid name
	mov		rax, [rdi]				; save struc password

	lea		rdi, [stat64]			; get gid
	add		rdi, st_gid			
	mov		rdi, [rdi]
	getgrgid						; get struc group
	mov		[gr], rax				; save struc group
	
	lea		rdi, [sUid]				; copy uid name
	mov		rsi, [pw]
	mov		rsi, [rsi]
	strcpy

	lea		rdi, [sGid]				; copy gid name
	mov		rsi, [gr]
	mov		rsi, [rsi]
	strcpy

	lea		rdi, [stat64]			; get file size
	add		rdi, st_nlink
	mov		rdi, [rdi]
	mov		[nFileSize], rdi

	lea		rdi, [stat64]			; get number of hard links
	add		rdi, st_nlink
	mov		rdi, [rdi]
	mov		[nHardLinks], rdi

	lea		rdi, [stat64]			; get file size
	add		rdi, st_size
	mov		rdi, [rdi]
	mov		[nFileSize], rdi

	lea		rdi, [stat64]			; get file modification time
	add		rdi, st_mtime
	mov		rdi, [rdi]
	mov		[mtime], rdi

	mov		eax, [nMode]
	and		eax, S_IFMT				; check file type

	cmp		rax, S_IFREG			; regular file
	je		.gotFileType

	cmp		rax, S_IFDIR			; directory
	mov		byte [perm], 'd'
	je		.gotFileType

	cmp		rax, S_IFLNK			; link
	mov		byte [perm], 'l'
	je		.gotFileType

	cmp		rax, S_IFIFO			; pipe (FIFO)
	mov		byte [perm], 'p'
	je		.gotFileType

	cmp		rax, S_IFSOCK			; socket
	mov		byte [perm], 's'
	je		.gotFileType

	cmp		rax, S_IFBLK			; block device
	mov		byte [perm], 'b'
	je		.gotFileType

	cmp		rax, S_IFCHR			; character device
	mov		byte [perm], 'c'
	je		.gotFileType

	mov		byte [perm], '?'

.gotFileType:						; check file permissions
	mov		eax, [nMode]
	test	eax, S_IRUSR			; owner read
	jz		.gotUserRead
	mov		byte [perm + 1], 'r'

.gotUserRead:
	test	eax, S_IWUSR			; owner write
	jz		.gotUserWrite
	mov		byte [perm + 2], 'w'

.gotUserWrite:
	test	eax, S_IXUSR			; owner execute
	jz		.gotUserExecute
	mov		byte [perm + 3], 'x'

.gotUserExecute:
	test	eax, S_IRGRP			; group read
	jz		.gotGroupRead
	mov		byte [perm + 4], 'r'

.gotGroupRead:
	test	eax, S_IWGRP			; group write
	jz		.gotGroupWrite
	mov		byte [perm + 5], 'w'

.gotGroupWrite:
	test	eax, S_IXGRP			; group execute
	jz		.gotGroupExecute
	mov		byte [perm + 6], 'x'

.gotGroupExecute:
	test	eax, S_IROTH			; other read
	jz		.gotOtherRead
	mov		byte [perm + 7], 'r'

.gotOtherRead:
	test	eax, S_IWOTH			; other write
	jz		.gotOtherWrite
	mov		byte [perm + 8], 'w'

.gotOtherWrite:
	test	eax, S_IXOTH			; other execute
	jz		.printPermissions
	mov		byte [perm + 9], 'x'

.printPermissions:
	mov		al, 'l'					; link
	cmp		byte [perm], al			; is the current file a link?
	jne		.next
	
	readlink [pFilePath], [pBuffer2], 64
	cmp		eax, -1
	je		.err2

.next:								; print item
	lea		rdi, [begItemFmt]
	lea		rsi, [perm]
	mov		rdx, [nHardLinks]
	lea		rcx, [sUid]
	lea		r8,	 [sGid]
	print

	mov		rdi, [nFileSize]		; get file size
	call	printFileSize			; print file size

	lea		rdi, [mtime]
	call	printFileTime

	print	[pBuffer2], [pBuffer1]

	puts	[pFilePath]
	jmp		.fin

.err1:
	perror [lstatName]				; return errno
	jmp		.exit

.err2:
	perror [rdlinkName]				; return errno
	jmp		.exit

.fin:
	zero    eax                     ; return EXIT_SUCCESS

.exit:
	epilogue
	
;============================================================================
main:
	prologue
	lea     rdi, [pFilePath]
	call	printFileInfo

.fin:
	epilogue

;============================================================================
section		.bss

	struc	stat64_struct			; structure declaration
		st_dev		resq	1		; stat_struct +   0
		st_ino		resq	1		;			  +   8
		st_nlink	resq 	1		;			  +  20		NOTE: ORDER OF TERMS
		st_mode		resd 	1		;			  +  16		file type and permissions 
		st_uid		resd	1		;			  +  28
		st_gid		resd	1		;			  +  32
		st_fill1	resd	1		;			  +  36		NOTE: ADDITION OF FILL TERM
		st_rdev		resq	1		;			  +	 40
		st_size		resq	1		;			  +  48
		st_blksize	resq	1		;			  +  56
		st_blocks 	resq	1		;			  +  64
		st_mtime	resq	1		;			  +  72		NOTE: ORDER OF TERMS
		st_atime	resq	1		;			  +  80
		st_ctime	resq	1		;			  +  88
	endstruc

	struc	pw_struct				; structure declaration
		pw_name		resq	1
		pw_passwd	resq	1
		pw_uid		resd	1
		pw_gid		resd	1
		pw_gecos	resq	1
		pw_dir		resq	1
		pw_shell	resq	1
	endstruc

	struc	gr_struct				; structure declaration
		gr_name		resq	1
		gr_passwd	resq	1
		gr_gid		resd	1
		gr_mem		resb  100
	endstruc

mtime		resq	 1
buffer		resb	40
sUid		resb	40
sGid		resb	40
nFileSize	resq	 1
nMode		resd	 1

section     .data

hardlinkFmt	db		"Hard links: %ld", LF, EOL
uidgidFmt	db		"uid: %d gid: %d", LF, EOL
nHardLinks	dq		0
sizeBufferFmt_0	db	"File size: %ld", LF, EOL
bufFmt		db		"%s", EOL
sizeBufFmt	db		"%.1f", EOL
fileSizeFmt	db		"%ld", LF, EOL

perm		db		'-', '-', '-', '-', '-', '-', '-', '-', '-', '-', ' ', EOL
begItemFmt	db		"%s%ld %s %s ", EOL		; perm nHardLinks mTime pFilePath
endItemFmt	db		"%s", LF, EOL

stat64	istruc	stat64_struct
		iend

pw		istruc	pw_struct
		iend

gr		istruc	gr_struct
		iend

lstatName	db		"lstat returned", EOL
rdlinkName	db		"rdlink returned", EOL
pFilePath	db		"theExe", EOL
pBuffer1	db		" -> %s ", EOL
pBuffer2	db		"                                                   ", EOL

;============================================================================
