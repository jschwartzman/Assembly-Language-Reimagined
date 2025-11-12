;============================================================================
; dir2.asm - retrieve ls info from OS and print it - eliminate .  and ..
; John Schwartzman, Forte Systems, Inc.
; 03/03/2024
; Linux x86_64
;
;============================ CONSTANT DEFINITIONS ==========================
NUM_VAR			equ	   6
ARG_SIZE		equ	   8		; size of argv vector
PATH_SEP		equ	  47		; ASCII '/' char
D_TYPE_OFFSET	equ	  18		; offset to dirent->d_type
D_NAME_OFFSET	equ	  19		; offset to dirent->d_name

%include "macro.inc"

global	main
; extern	opendir, readdir, closedir

DT_UNKNOWN	equ	 0				; dirent file types
DT_FIFO		equ	 1
DT_CHR		equ	 2
DT_BLK		equ  6
DT_DIR		equ	 4
DT_REG		equ	 8
DT_LNK		equ	10
DT_SOCK		equ	12

__S_IFREG	equ	0100000			; regular file
__S_IFDIR	equ	0040000			; directory
__S_IFLNK	equ	0120000			; symbolic link			
__S_IFIFO	equ	0100000			; fifo (pipe)
__S_IFSOC	equ	0140000			; socket
__S_IFBLK	equ	0060000			; block
__S_IFCHR	equ	0020000			; character

__S_IEXEC	equ	0100			; execute by owner (user)

S_IRUSR		equ	0400			; user read permission
S_IWUSR		equ	0200			; user write permission
S_IXUSR		equ	0100			; user execute permission
S_IRGRP		equ	0040			; group read permission
S_IWGRP		equ	0020			; group write permission
S_IXGRP		equ	0010			; group execute permission
S_IROTH		equ	0004			; group read permission
S_IWOTH		equ	0002			; other read permission
S_IXOTH		equ	0001			; other execute permission

S_IFMT		equ 0170000

;========================== DEFINE LOCAL VARIABLES ==========================103
%define	argc 		qword [rsp + VAR_SIZE * (NUM_VAR - 6)]	; rsp +  0
%define	argv0 		qword [rsp + VAR_SIZE * (NUM_VAR - 5)]	; rsp +  8
%define	dir			qword [rsp + VAR_SIZE * (NUM_VAR - 4)]	; rsp + 16
%define	type		qword [rsp + VAR_SIZE * (NUM_VAR - 3)]	; rsp + 24
%define dirent  	qword [rsp + VAR_SIZE * (NUM_VAR - 2)]  ; rsp + 32
%define nEntries	qword [rsp + VAR_SIZE * (NUM_VAR - 1)]	; rsp + 40
;============================== CODE SECTION ================================

section	.text

printFileInfo:						; arg is fileName
	prologue						; *** NUM_VAR will be determined later ***

	lea			rsi, [stat]			; rdi already points to fileName
	lstat							; call lstat

	mov			rdi, [stat + st_uid]
	getpwuid
	mov			[pw], rax

	mov			rdi, [stat + st_gid]
	getgrgid	
	mov			[gr], rax

	mov			rax, [stat + st_mode]
	and			rax, S_IFMT			; rax now contains type info

	test		rax, __S_IFREG		; test for regular file
	mov			byte [filePerm + 0], '-'	; it's a regular file
	jnz			.next0
	
	test		rax, __S_IFDIR		; test for directory
	mov			byte [filePerm + 0], 'd'	; it's a directory
	jnz			.next0

	test		rax, __S_IFLNK		; test for symbolic link
	mov			byte [filePerm + 0], 'l'	; it's a symbolic link
	jnz			.next0

	test		rax, __S_IFIFO				
	mov			byte [filePerm + 0], 'p'	; it's a FIFO (pipe)
	jnz			.next0

	test		rax, __S_IFBLK				
	mov			byte [filePerm + 0], 'b'	; it's a block device
	jnz			.next0

	test		rax, __S_IFCHR
	mov			byte [filePerm + 0], 'c'	; it's a character device`
	jnz			.next0
	mov			byte [filePerm + 0], '?'	; unknown type - we should never get here

.next0:
	mov			rax, [stat + st_mode]		; test st_mode
	test		rax, S_IRUSR
	mov			byte [filePerm + 1], 'r'
	jnz			.next1
	mov			byte [filePerm + 1], '-'

.next1:
	test		rax, S_IWUSR
	mov			byte [filePerm + 2], 'w'
	jnz			.next2
	mov			byte [filePerm + 2], '-'

.next2:
	test		rax, S_IXUSR
	mov			byte [filePerm + 3], 'x'
	jnz			.next3
	mov			byte [filePerm + 3], '-'

.next3:
	test		rax, S_IRGRP
	mov			byte [filePerm + 4], 'r'
	jnz			.next4
	mov			byte [filePerm + 4], '-'

.next4:
	test		rax, S_IWGRP
	mov			byte [filePerm + 5], 'w'
	jnz			.next5
	mov			byte [filePerm + 5], '-'

.next5:
	test		rax, S_IXGRP
	mov			byte [filePerm + 6], 'x'
	jnz			.next6
	mov			byte [filePerm + 6], '-'

.next6:
	test		rax, S_IROTH
	mov			byte [filePerm + 7], 'r'
	jnz			.next7
	mov			byte [filePerm + 7], '-'

.next7:
	test		rax, S_IWOTH
	mov			byte [filePerm + 8], 'r'
	jnz			.next8
	mov			byte [filePerm + 8], '-'

.next8:
	test		rax, S_IXOTH
	mov			byte [filePerm + 8], 'r'
	jnz			.next9
	mov			byte [filePerm + 8], '-'

.next9:
	mov			byte [filePermDelim], 0

.printPerm:
	print		[permFmt], [filePerm]

	print	[usrGrpFmt], [pw + pw_name], [gr + gr_name]
	print	[prtNameFmt], [fileName]

.fin:
	epilogue

main:
	prologue NUM_VAR				; setup stack and space for 6 local var
	mov		argc, rdi				; argc  = rdi (1st arg to main)
	mov		argv0, rsi				; argv0 = rsi (2nd arg to main)
	zero	rax
	mov		nEntries, rax

	cmp		rdi, 1					; more than 1 arg?
	je		.getDefaultPath					;   jump if no

	lea		rdi, [path]				; rdi => path[]  <= dest
	mov		rsi, [rsi + ARG_SIZE]	; rsi => argv[1] <= src
	strcpy
	jmp		.terminatePath

.getDefaultPath:
	strcpy	[path], [current_dir]	;  path = "./"

.terminatePath:
	lea		rdi, [path]
	strlen							; rax = strlen(path)

	lea		rdi, [path]
	dec		rax						; rax => last char of path
	mov		dl, PATH_SEP
	cmp		[rdi + rax], dl			; does rdi end with a '/'?
	je		.chdir					; 	jump if yes

	inc		rax						; strlen++
	lea		rdi, [path]
	mov		[rdi + rax], dl			; append '/'
	inc		rax						; strlen++
	zero	dl
	lea		rdi, [path]
	mov		[rdi + rax], dl			; append EOL

.chdir:
	lea		rdi, [path]
	chdir							; getFileType needs us to chdir 
	jz		.opendir				;	jump if successfully changed

	lea		rsi, [path]				; invalid directory selection
	print	[errFmt]				; print error message
	jmp		.fin					; and exit

.opendir:
	lea		rdi, [path]
	opendir							; rax = opendir(path)
	mov		dir, rax				; save dir
	jz		.fin					;   jump if dir is NULL 

.top_of_loop:
	mov     rdi, dir
	readdir	dir						; rax = readdir(dir)
	mov	    dirent, rax				; Dirent <- rax
	jz		.fin					;    jump if DIR is NULL

	; rdstruc dirent, D_NAME_OFFSET	; get file name
	mov		rsi, dirent					; struct
	add		rsi, D_NAME_OFFSET		; offset
    mov     rsi, [rsi]				; dest string
	lea		rdi, [fileName]
	strcpy

	call	printFileInfo




	rdstruc dirent, D_TYPE_OFFSET	; get file  type
	mov		rax, [rdi]

	cmp		al, DT_REG
	lea		rdx, [dt_reg]			; 3rd arg to print
	je		.printFileType

	cmp		al, DT_DIR
	lea		rdx, [dt_dir]			; 3rd arg to print
	je		.printFileType

	cmp		al, DT_LNK
	lea		rdx, [dt_lnk]			; 3rd arg to print
	je		.printFileType

	cmp		al, DT_FIFO
	lea		rdx, [dt_fifo]			; 3rd arg to print
	je		.printFileType

	cmp		al, DT_CHR
	lea		rdx, [dt_chr]			; 3rd arg to print
	je		.printFileType

	cmp	al, DT_BLK
	lea		rdx, [dt_blk]			; 3rd arg to print
	je		.printFileType

	cmp		al, DT_SOCK
	lea		rdx, [dt_sock]			; 3rd arg to print
	je		.printFileType

	lea		rdx, [dt_unknown]		; 3rd arg to print

.printFileType:
	; cmp		al, DT_DIR				; only list directories
	; jne		.top_of_loop

	rdstruc dirent, D_NAME_OFFSET	; get directory name
	lea		rsi, [rdi]
	lea		rdi, [fileName]
	strcpy

	call	printFileInfo

	; lea		rsi, [rdi]				; 2nd arg to printf -file name

	lea		rdi, [this_dir]			; eliminate '.'
	strcmp							; file name === '.'?
	je		.top_of_loop			;	jump if yes

	lea		rdi, [parent_dir]		; eliminate '..'
	strcmp							; file name = '..'?
	je		.top_of_loop			; 	jump if yes

	; print	[prtFmt]				; 1st arg to printf
	call printFileInfo
	inc		nEntries
	jmp		.top_of_loop				; continue for other dir entries

.fin:
	mov		rsi, nEntries
	print	[prtFmtTotal]
	mov	    rdi, dir
	closedir						; closedir(dir)
	zero	rax						; return EXIT SUCCESS
	epilogue

;=========================== READ-ONLY DATA SECTION =========================
section	.rodata
prtFmt		db TAB, "%s (%s)", LF, EOL
prtFmtTotal	db "%2d entries found.", LF, LF, EOL
prtNameFmt	db " %s", LF, EOL
fileName	db	64
current_dir	db "./", EOL
this_dir	db ".", EOL
parent_dir	db "..", EOL
permFmt		db "%s ", EOL
usrGrpFmt	db "%s %s ", EOL
errFmt		db "%s is not a valid directory!", LF, EOL
dt_unknown	db	"unknown", EOL		; dirent file types
dt_fifo		db	"fifo", EOL
dt_chr		db	"char", EOL
dt_blk		db	"block", EOL
dt_dir		db	"dir", EOL	 
dt_reg		db	"reg", EOL
dt_lnk		db	"link", EOL
dt_sock		db	"socket", EOL

section  .bss
path		resb	256

filePerm		resb	10
filePermDelim	resb	1

	STRUC	stat
st_dev			resq	1	; device
st_ino			resq	1	; file serial number
st_nlink		resq	1	; link count	
st_mode			resq	1	; file mode
st_uid			resq	1	; uid of file owner
st_gid			resq	1	; gid of file group
st_pad0			resq	1
st_rdev			resq	1	; device number
st_size			resq	1	; size of file in bytes
st_blksize		resq	1	; size of st_blocks
st_blocks		resq	1	; number of st_blocks
st_atime		resq	1	; time of last access
st_atimensec	resq	1	; ns of last access
st_mtime		resq	1	; time of last modification
st_mtimensec	resq	1	; ns of last modification
st_ctime		resq	1	; time of last status changed
st_ctimensec	resq	1	; ns of last status changed
st_glibc_resv	resq	3
	ENDSTRUC

	STRUC	pw
pw_name		resq	1
pw_passwd	resq	1
pw_uid		resq	1
pw_gid		resq	1
pw_gecos	resq	1
pw_dir		resq	1
pw_shell	resq	1
	ENDSTRUC

	STRUC	gr
gr_name		resq	1
gr_passwd	resq	1
gr_gid		resq	1
gr_mem		resq	1
	ENDSTRUC
;============================================================================
