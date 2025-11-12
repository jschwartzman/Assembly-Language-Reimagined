;============================================================================
; fi.asm
; John Schwartzman, Forte Systems, Inc.
; 05/18/2024
; Linux x86_64
;============================================================================
%include	"macro.inc"

global	    main
;global		printFileInfo

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

;================== DEFINE LOCAL VARIABLES for printModFileTime ==============
%define		buffer	qword [rsp + 0]		; size 48 bytes

%define	NUM_VAR		6		; round up to next even value

;================== DEFINE LOCAL VARIABLES for printFileInfo =================
%define		fp		qword [rsp + VAR_SIZE * (NUM_VAR - 6)]	; rsp +  0
%define		st	 	qword [rsp + VAR_SIZE * (NUM_VAR - 5)]	; rsp +  8
%define		pw	 	qword [rsp + VAR_SIZE * (NUM_VAR - 4)]	; rsp + 16
%define		gr		qword [rsp + VAR_SIZE * (NUM_VAR - 3)]	; rsp + 24
%define		mode	dword [rsp + VAR_SIZE * (NUM_VAR - 2)]	; rsp + 32

;============================== CODE SECTION ================================
section	.text

printFileModTime:
	prologue 2
	sub		rsp, 64					; leave space for buffer on stack

	lea		rdi, [mtime]
	localtime
	mov		[tm], rax

	lea		rdi, buffer
	mov		rsi, 40
	lea		rdx, [tdFmt]
	mov		rcx, [tm]
	strftime

	print	buffer
	epilogue

;============================================================================
printFileInfo:
	prologue	NUM_VAR

	lea		rdi, [pFilePath]
	lea		rsi, [stat64]
	lstat							; fill stat structure for this file
	jnz		.err1					; error: return with rax = -1

	lea		eax, dword [stat64]
	add		eax, st_uid				; get offset of uid
	mov		esi, [eax]

	lea		eax, dword [stat64]
	add		eax, st_gid				; get offset of gid
	mov		edx, [rax]

	lea		rsi, qword [stat64]
	add		rsi, st_nlink
	mov		rsi, [rsi]
	mov		[nHardLinks], rsi		; save nHardLinks

	lea		rdi, [fileSizeFmt]		; get file size
	lea		rsi, qword [stat64]
	add		rsi, st_size
	mov		rsi, [rsi]
	mov		[nFileSize], rsi

	lea		rsi, qword [stat64]		; get mode
	add		rsi, st_mode
	mov		esi, [rsi]
	mov		mode, esi

	lea		rdi, [stat64]			; get uid
	add		rdi, st_uid
	mov		rdi, [rdi]
	getpwuid						; get struc password
	mov		pw, rax

	lea		rdi, pw					; get gid name
	mov		rax, [rdi]				; save struc password

	lea		rdi, [suid]
	mov		rsi, rax
	strcpy							; save string uid

	lea		rdi, [stat64]			; get gid
	add		rdi, st_gid			
	mov		rdi, [rdi]
	getgrgid						; get struc group
	mov		qword gr, rax			; save struc group

	lea		rdi, [sgid]
	mov		rsi, rax
	strcpy							; save string gid

; getFileType:
	mov		eax, mode
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
	; lea		rdi, [modeFmt]
	; mov		esi, mode
	; print

	mov		eax, mode
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
	jz		.printInfo
	mov		byte [perm + 9], 'x'

.printInfo:
	lea		rdi, [sInfoFmt]
	lea		rsi, [perm] 
	mov		rdx, [nHardLinks]
	lea		rcx, [suid]
	lea		r8,  [sgid]
	; lea		r9,  [sSize]
	print

	lea		rdi, [stat64]			; get ctime
	add		rdi, st_mtime
	mov		rdi, [rdi]
	mov		[mtime], rdi
 	call	printFileModTime

	mov		al, 'l'					; link
	cmp		byte [perm], al			; is the current file a link?

	readlink [pFilePath], [pBuffer2], 64
	cmp		eax, -1
	je		.err2

	print	[pBuffer1], [pBuffer2]	; print the symbolic link

	; print [sInfoFmt], [perm], [nLinks], [suid], [sgid], [nSize]
	; lea 	rdi, [sInfoFmt]
	; lea 	rsi, [perm]
	; mov		rdx, [nLinks]
	; lea		rcx, [suid]
	; lea		r8,  [sgid]
	; mov		r8,  [nSize]


.err1:
	perror [lstatName]				; return errno
	jmp		.exit

.err2:
	perror	[rlinkName]				; return errno
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

	struc	pw_struct				; structure declarration
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

	struc	tm_type
		tm_sec		resd	1
		tm_min		resd	1
		tm_hour		resd	1
		tm_mday		resd	1
		tm_mon		resd	1
		tm_year		resd	1
		tm_wday		resd	1
		tm_yday		resd	1
		tm_isdst	resd	1
	endstruc

mtime	resd	1

section     .data

fileSizeFmt	db		"File Size: %ld", LF, EOL
nSizeFmt	db		" %5ld ", EOL
hardlinkFmt	db		"Hard links: %ld", LF, EOL
uidgidFmt	db		"uid: %d gid: %d", LF, EOL
permFmt		db		"%s", EOL
filePathFmt	db		"File Path: %s", LF, EOL
uidgidSFmt	db		"uid: %s gid: %s", LF, EOL
modeFmt		db		"mode: %jo (octal)", LF, EOL
rdlinkFmt	db		" -> %s", LF, EOL
tdFmt		db		"%b %d %H:%M", LF, EOL
perm		db		'-', '-', '-', '-', '-', '-', '-', '-', '-', '-', ' ', EOL
lstatName	db		"lstat returned", EOL
rlinkName	db		"rlink returned", EOL

pFilePath	db		"theExe", EOL
pBuffer1	db		" -> %s", LF, EOL
pBuffer2	db		"                                                   ", EOL
sInfoFmt	db		"%s %ld %s %s %ld "; perm nHardLinks suid sgid 
suid		db		5
sgid		db		5
nHardLinks	dq		1
sSize		db		10
stimeDate	db		10
nFileSize	dq		1

stat64	istruc	stat64_struct
		iend

tm		istruc	tm_type
		iend

;============================================================================
