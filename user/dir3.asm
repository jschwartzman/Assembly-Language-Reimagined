;============================================================================
; dir3.asm - retrieve ls info from the OS, sort & print it (ignores . and ..)
; John Schwartzman, Forte Systems, Inc.
; 03/16/2024
; Linux x86_64
;
;============================ CONSTANT DEFINITIONS ==========================
NUM_VAR			equ	   6		; for main - round up to even number
ARG_SIZE		equ	   8		; size of argv vector
PATH_SEP		equ	  '/'		; ASCII '/' char
D_NAME_OFFSET	equ	  19		; offset to dirent->d_name

%include "macro.inc"

%define __quicksort__

global	main
global	newNode		;, dirNameT
extern	fileName, filePath
extern	printFileInfo, swapij		; tell assembler/linker about ext
extern	quicksortStr, bubblesortStr	; global procedures
extern	getElement, putElement
extern  insertNode, traverseList
extern	freeList, createHeadNode
extern	pTemp, pTempi, pTempj		; external data
extern	listIndex
; extern	stat, stat_size
;======================= DEFINE LOCAL VARIABLES (main) ======================
%define	argc 	qword [rsp + VAR_SIZE * (NUM_VAR - 6)]	; rsp +  0
%define	argv0 	qword [rsp + VAR_SIZE * (NUM_VAR - 5)]	; rsp +  8
%define	dir		qword [rsp + VAR_SIZE * (NUM_VAR - 4)]	; rsp + 16
%define dirent  qword [rsp + VAR_SIZE * (NUM_VAR - 3)]  ; rsp + 24
%define nRec	qword [rsp + VAR_SIZE * (NUM_VAR - 2)]	; rsp + 32

;============================== CODE SECTION ================================
section	.text

;============================================================================
main:
	prologue NUM_VAR				; setup stack and space for 6 local var
	mov		argc, rdi				; argc  = rdi (1st arg to main)
	mov		argv0, rsi				; argv0 = rsi (2nd arg to main)
	mov		nRec, 0					; zero record count

	cmp		rdi, 1					; more than 1 arg?
	je		.next0					;   jump if no

	lea		rdi, [path]				; rdi => path[]  <= dest
	mov		rsi, [rsi + ARG_SIZE]	; rsi => argv[1] <= src
	strcpy
	jmp		.next1

.next0:
	lea		rdi, [path]				; only one local var
	lea		rsi, [cur_dir]			; src  => "./"
	strcpy	

.next1:
	lea		rdi, [path]
	strlen
	dec		rax							; rax => last char of path
	lea		rdi, [path]
	cmp		byte [rdi + rax], PATH_SEP 	; does rdi end with a '/'?
	je		.next2						; 	jump if yes

	strcat	[path], [pathSepStr]		; make sure path ends with a '/]'

.next2:
	chdir	[path]					; printFileInfo needs us to chdir 
	jz		.next3					; jump if chdir successfull

	print	[errFmt], [path]		; print error message
	jmp		.err					; and exit

.next3:
	getcwd
	mov		dir, rax				; save path
	mov		rdi, dir
	opendir							; rax = opendir(path)
	mov		dir, rax
	jz		.err					; jump if dir is null 

	; call	createHeadNode

.top_of_loop:
	mov     rdi, dir				; prepare for readdir
	readdir							; rax = readdir(dir)
	mov	    dirent, rax				; Dirent <- rax
	jz		.fin					; jump if NULL

    ; remove parent_dir (../) from list of files
    rdstruc dirent, D_NAME_OFFSET
    lea     rsi, [parent_dir]
    strcmp							; is this parent dir
    jz      .top_of_loop 			;	yes, get another file

    ; remove current_dir (./) from list of files
    rdstruc	dirent, D_NAME_OFFSET
    lea     rsi, [current_dir]		
    strcmp							; is this current dir
    jz      .top_of_loop			;	yes, get another file


	rdstruc	dirent, D_NAME_OFFSET
	lea		rsi, [rdi]				; get current file
	lea		rdi, [fileName]			
	strcpy							; and copy it to fileName

	strcpy	[filePath], [path]
	strcat	[filePath], [pathSepStr]
	chdir	[filePath]				; append '/' to current file path

	; lea		rdi, [filePath]

 	; save type and path of entry in new node
    rdstruc dirent, D_NAME_OFFSET
	lea		rsi, [rdi]
	lea		rdi, [filePath]
	strcat
	lea		rdi, [filePath]
	call	printFileInfo			; get file's type, perm, owner info and name
	
	; create new node and insert it at the front of the list
	; lea		rdi, [dirNameT]
	; mov		rcx, nRec
	; call	insertNode				; rdi -> noteName, rsi -> nodeType

	inc		nRec
	jmp		.top_of_loop			; continue for other dir entries

.bottomOfLoop:
	; puts	[unsorted]
	; mov		rdi, nRec
	; call	traverseList
	
; %ifdef __bubblesort__

;  	puts	[bsorted]
; 	mov		rdi, 0					; i = nLow
; 	mov		rsi, nRec 				; nHigh 						
; 	dec		rsi						; j = nHigh = nRec - 1
; 	call	bubblesortStr

; %elifdef __quicksort__

; 	puts	[qsorted]
; 	mov		rdi, 0					; nLow = 0
; 	mov		rsi, nRec			
; 	dec		rsi						; nHigh = number of records - 1
; 	call	quicksortStr

; %endif

	; mov		rdi, nRec
	; call	traverseList
	; call	freeList

	zero	rax						; return EXIT_SUCCESS
	jmp		.fin

.err:
	mov	    rdi, dir
	closedir						; closrdir(dir)
	puts	[blankline]
	mov		rax, EXIT_FAILURE

.fin:
	epilogue

;=========================== READ-ONLY DATA SECTION =========================
section	.rodata
cur_dir		db "./", EOL
errFmt		db "ERROR: %s is not a valid directory!", LF, EOL
parent_dir  db  "..", EOL
current_dir db  ".", EOL
blankline	db EOL
unsorted	db LF, "Insertion sorted List:", EOL
bsorted		db LF, "Bubblesorted List:", EOL
qsorted		db LF, "Quicksorted List:", EOL
pathSepStr	db	"/", EOL
;========================= UNINITIALIZED DATA SECTION =======================
section .bss
path	resb	MAX_PATH
headNode		dq		1
newNode			dq		1
; fileName		resb	64
; filePath		resb   128

;============================================================================
