;============================================================================
; arrayDir.asm - retrieve ls info from the OS, sort & print it (ignores . and ..)
; John Schwartzman, Forte Systems, Inc.
; 11/29/2023		Link with arrayTools, bubblesortStr, quicksortStr
; Linux x86_64
;
;============================ CONSTANT DEFINITIONS ==========================
ARG_SIZE		equ	  	 8		; size of argv vector
PATH_SEP		equ	  	47		; ASCII '/' char
D_TYPE_OFFSET	equ	  	18		; offset to dirent->d_type
D_NAME_OFFSET	equ	  	19		; offset to dirent->d_name
ELEMENT_SIZE	equ	  	64
ARRAY_SIZE		equ		4096
FACTOR			equ		1000000	; 1,000,000 yields 5s - 10s

%include "macro.inc"

global	main
extern	opendir, readdir, closedir
extern	qsortPartStr, bubblesortStr
extern	getElement, putElement
extern  displayArray
extern  swapij						; external proccedures
extern	array, pTempi, pTempj		; external data

DT_UNKNOWN	equ	 0		; dirent file types - from /usr/include/dirent.h
DT_FIFO		equ	 1
DT_CHR		equ	 2
DT_DIR		equ	 4
DT_BLK		equ  6
DT_REG		equ	 8
DT_LNK		equ	10
DT_SOCK		equ	12

;==================== DEFINE LOCAL VARIABLES (main) =========================
NUM_VAR			equ	   	 6		; rounded up to even number

%define nRecords    qword [rsp + VAR_SIZE * (NUM_VAR - 6)]	; rsp +  0
%define	argc 		qword [rsp + VAR_SIZE * (NUM_VAR - 5)]	; rsp +  8
%define	argv0 		qword [rsp + VAR_SIZE * (NUM_VAR - 4)]	; rsp + 16
%define	dir			qword [rsp + VAR_SIZE * (NUM_VAR - 3)]	; rsp + 24
%define dirent  	qword [rsp + VAR_SIZE * (NUM_VAR - 2)]  ; rsp + 32

;==================== DEFINE LOCAL VARIABLES (loopXsorted) =========================
%define nRecords    qword [rsp + 0]		; rsp +  0

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

	print2Str	[errFmt], [path]
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

	rdstruc dirent, D_TYPE_OFFSET	; get file  type
	mov		rax, [rdi]

	cmp		al, DT_REG
	lea		rsi, [dt_reg]			
	je		.getFileType

	cmp		al, DT_DIR
	lea		rsi, [dt_dir]
	je		.getFileType

	cmp		al, DT_LNK
	lea		rsi, [dt_lnk]
	je		.getFileType

	cmp		al, DT_FIFO
	lea		rsi, [dt_fifo]			
	je		.getFileType

	cmp		al, DT_CHR
	lea		rsi, [dt_chr]			
	je		.getFileType

	cmp		al, DT_BLK
	lea		rsi, [dt_blk]			
	je		.getFileType

	cmp		al, DT_SOCK
	lea		rsi, [dt_sock]			
	je		.getFileType

	lea		rsi, [dt_unknown]		

.getFileType:
	lea		rdi, [fileType]
	strcpy							; copy fileType

	rdstruc dirent, D_NAME_OFFSET	; get directory name
	lea		rsi, [rdi]
	lea		rdi, [fileName]
	strcpy							;  copy fileName

	lea		rsi, [parent_dir]
	strcmp
	jz		.top_of_loop

	lea		rsi, [this_dir]
	strcmp
	jz		.top_of_loop

	strcat 	[fileName], [fileType]	; concatenate 
	lea		rsi, [fileName]
	mov		rcx, nRecords
	call	putElement				;  create new elemeent - rsi => array[rcx]
	inc		nRecords
	jmp		.top_of_loop			; continue for other dir entries

.fin:
	print1Str1Int	[prtFmtTotal], nRecords
	
	mov	    rdi, dir
	call	closedir

	print1StrLF	[unsorted]
	mov		rdi, nRecords
	call	displayArray

%ifdef __bubblesort__				; ------------------------

 	print1StrLF	[bsorted]
	zero	rdi						; i = nLow
	mov		rsi, nRecords			; nHigh
	call	loopBsorted

%endif								; ------------------------
%ifdef __quicksort__

	print1StrLF	[qsorted]
	zero	rdi
	mov		rsi, nRecords
	call	loopQsorted

%endif								; ------------------------

	mov		rdi, nRecords			; displayArray
	call	displayArray

.err:
	time
	mov		[timeStop], rax
	sub		rax, [timeStart]
	print1Str1Int	[timeElapsed], rax

	epilogue EXIT_SUCCESS


%ifdef __bubblesort__				; ------------------------
;============================================================================
loopBsorted:
	prologue 2

	mov		nRecords, rsi

	time
	mov		[timeStart], rax

	zero	rdx

.beginLoop:
	mov		rsi, nRecords
	dec		rsi						; high
	zero	rdi						; low
	push	rdx
	call	bubblesortStr
	pop		rdx
	inc		rdx
	cmp		rdx, FACTOR
	je		.endLoop

	jmp		.beginLoop
		
.endLoop:
	epilogue

%elifdef __quicksort__				; ------------------------

;============================================================================
loopQsorted:
	prologue 2
	
	mov		nRecords, rsi

	time		
	mov		[timeStart], rax

	zero	rdx

.beginLoop:
	zero	rdi						; nLow
	mov		rsi, nRecords			; nHigh
	push	rdx
	call	qsortPartStr
	pop		rdx
	inc		rdx
	cmp		rdx, FACTOR
	je		.endLoop

	jmp		.beginLoop

.endLoop:
	epilogue

%endif								; ------------------------

;=========================== READ-ONLY DATA SECTION =========================
section	.rodata
prtFmt		db TAB, "%s (%s)", LF, EOL
prtFmtTotal	db "%2d entries found.", LF, LF, EOL
this_dir	db ".", EOL
parent_dir  db "..", EOL
current_dir db "./", EOL
path_sep	db "/", EOL
errFmt		db "ERROR: %s is not a valid directory!", LF, LF, EOL
unsorted	db LF, "Insertion Sorted Array:", EOL
bsorted		db LF, "Bubblesorted Array:", EOL
qsorted		db LF, "Quicksorted Array:", EOL
timeElapsed	db LF, "Elapsed time: %lds", LF, EOL 
dt_unknown	db	"  (unknown)", EOL		; dirent file types
dt_fifo		db	" (fifo)", EOL
dt_chr		db	" (char)", EOL
dt_blk		db	" (block)", EOL
dt_dir		db	" (dir)", EOL	 
dt_reg		db	" (reg)", EOL
dt_lnk		db	" (link)", EOL
dt_sock		db	" (socket)", EOL
;========================= UNINITIALIZED DATA SECTION =======================
section .bss
path			resb	64
fileName		resb	64
fileType		resb	64
timeStart		resq	 1
timeStop		resq	 1
;============================================================================
