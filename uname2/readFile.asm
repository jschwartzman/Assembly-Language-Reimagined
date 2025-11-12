;============================================================================
; readFile.asm - read and print distro info from file /etc/os-release
; John Schwartzman, Forte Systems, Inc.
; 06/02/2023
; linux x86_64
;
;============================ CONSTANT DEFINITIONS ==========================
BUFF_SIZE		equ    1024			; number of bytes in buffer
LF				equ 	 10			; ASCII line feed character
EOL   			equ 	  0			; end of line character
TAB				equ 	  9			; ASCII tab character
NULL            equ       0
VAR_SIZE		equ 	  8			; each local var is 8 bytes
NUM_VAR			equ		  2			; number local var (round up to even num)
;
;=============================== DEFINE MACRO ===============================
%macro      zero    1
	xor     %1, %1
%endmacro

;========================== DEFINE LOCAL VARIABLES ==========================
%define		fp		qword [rsp + VAR_SIZE * (NUM_VAR - 2)]		; rsp + 0

;============================== CODE SECTION ================================
section     .text
global      main                    ; gcc expects to find the label main
extern		printf	                ; tell linker about external functions
extern		fopen, fgets, fclose	; tell linker about external functions

printBlankLine:
	push	rbp						; set up stack frame
	mov		rbp, rsp				; set up stack frame - stack is aligned

	lea     rdi, [newLine]          ; print blank line
	zero    rax
	call    printf

	leave
	ret

main:								; beginning of program
	push	rbp						; set up stack frame
	mov		rbp, rsp				; set up stack frame - stack is aligned
	sub     rsp, NUM_VAR * VAR_SIZE ; make space on stack for fp

openFile:
	lea     rdi, [fileName]			; open file
	lea     rsi, [fileMode]
	call    fopen
	mov     fp, rax                 ; save file pointer fp
	or      rax, rax                ; fopen success?
	jl      exit                    ;   if no, exit

	call	printBlankLine

readFile:
	lea     rdi, [fileBuf]
	mov     rsi, BUFF_SIZE
	mov     rdx, fp
	call    fgets                   ; read into file buffer
	or      rax, rax                ; read 0 bytes?                ;
	jz      closeFile				;	jump if yes	

	lea     rdi, [fileBuf]			; print line of text
	zero    rax
	call    printf
	jmp     readFile

closeFile:
	call	printBlankLine

	mov     rdi, fp					; close the file
	call    fclose					; returns with EXIT_SUCCESS (0)                

exit:	
	leave
	ret

;========================= READ-ONLY DATA SECTION ===========================
section     .rodata
fileName	db      "/etc/os-release", EOL
fileMode    db      "r", EOL
newLine     db      LF, EOL			;read-only

;========================== UNINITIALIZED DATA SECTION ======================
section     .bss
fileBuf     resb    BUFF_SIZE;

;============================================================================
