;============================================================================
; dir.asm - retrieve ls info from the OS, sort & print it (ignores . and ..)
; John Schwartzman, Forte Systems, Inc.
; 06/17/2023
; Linux x86_64
;
;============================ CONSTANT DEFINITIONS ==========================
NUM_VAR			equ	   	 6		; rounded up to even number
ARG_SIZE		equ	  	 8		; size of argv vector
PATH_SEP		equ	  	47		; ASCII '/' char
D_TYPE_OFFSET	equ	  	18		; offset to dirent->d_type
D_NAME_OFFSET	equ	  	19		; offset to dirent->d_name
ELEMENT_SIZE	equ	  	64
ARRAY_SIZE		equ		4096

%include "macro.inc"

global	main
extern	opendir, readdir, closedir

;==================== DEFINE LOCAL VARIABLES (main) =========================
%define nRecords    qword [rsp + VAR_SIZE * (NUM_VAR - 6)]	; rsp +  0
%define	argc 		qword [rsp + VAR_SIZE * (NUM_VAR - 5)]	; rsp +  8
%define	argv0 		qword [rsp + VAR_SIZE * (NUM_VAR - 4)]	; rsp + 16
%define	dir			qword [rsp + VAR_SIZE * (NUM_VAR - 3)]	; rsp + 24
%define dirent  	qword [rsp + VAR_SIZE * (NUM_VAR - 2)]  ; rsp + 32
;============================== CODE SECTION ================================
section	.text

;============================================================================
main:
	prologue NUM_VAR				; setup stack and space for 4 local var
	mov		argc, rdi				; argc  = rdi (1st arg to main)
	mov		argv0, rsi				; argv0 = rsi (2nd arg to main)
	zero	rax
	mov		nRecords, rax			; zero record count
	cmp		rdi, 1					; more than 1 command line arg?
	je		.getCurrentDir			;   jump if no

	lea		rdi, [path]				; rdi => path[]  <= dest
	mov		rsi, [rsi + ARG_SIZE]	; rsi => argv[1] <= src
	strcpy
	jmp		.terminatePath

.getCurrentDir:
	lea		rdi, [path]
	lea		rsi, [current_dir]			; src  => "./"
	strcpy	

.terminatePath:
	lea		rdi, [path]
	strlen							; rax = strlen(path)
	
	lea		rdi, [path]
	dec		rax						; rax => last char of path
	cmp		byte [rax + rdi], PATH_SEP
	je		.chdir					; 	jump if yes

	lea		rsi, [path_sep]
	strcat

.chdir:
	chdir	[path]					; getFileType needs us to chdir 
	jz		.opendir				;	jump if yes

	lea		rsi, [path]				; invalid directory selection
	print	[errFmt]				; print error message
	jmp		.err					; and exit

.opendir:
	lea		rdi, [path]
	call	opendir					; rax = opendir(path)
	mov		dir, rax				; save dir
	rdflags	rax						; is dir null?
	jz		.err					;    jump if yes 

.top_of_loop:
	mov     rdi, dir
	call	readdir					; rax = readdir(dir)
	mov	    dirent, rax				; Dirent <- rax
	rdflags	rax						; is dirent NULL?
	jz		.fin					;    jump if yes (exit)

.fin:
	mov		rsi, nRecords
	print	[prtFmtTotal]
	
	mov	    rdi, dir
	call	closedir

	; puts	[unsorted]
	mov		rdi, nRecords
	; call	displayArray

	; mov		rdi, nRecords
	; call	displayArray
	puts	[blankline]

.err:
	epilogue EXIT_SUCCESS

;=========================== READ-ONLY DATA SECTION =========================
section	.rodata
prtFmt		db TAB, "%s (%s)", LF, EOL
prtFmtTotal	db "%2d entries found.", LF, LF, EOL
this_dir	db ".", EOL
parent_dir  db "..", EOL
current_dir db "./", EOL
path_sep	db "/", EOL
errFmt		db "ERROR: %s is not a valid directory!", LF, LF, EOL
blankline	db EOL

;========================= UNINITIALIZED DATA SECTION =======================
section .bss
path			resb	64
fileName		resb	64
fileType		resb	64
;============================================================================
