;============================================================================
; random.asm - guessing game - calls random.c   - Activity 5.7
; John Schwartzman, Forte Systems, Inc.
; 05/31/2023
; linux x86_64
;
;============================ CONSTANT DEFINITIONS ==========================
LF              equ		10			; ASCII linefeed char
EOL             equ		 0			; end of line
TAB				equ		 9			; ASCII tab char
ARG_SIZE		equ		 8			; size of argv vector & size of a push
VAR_SIZE		equ 	 8			; each local var is 8 bytes
NUM_VAR			equ		 2			; number local var (round up to even num)

;========================== DEFINE LOCAL VARIABLES ==========================
%define		number 		qword [rsp + VAR_SIZE * (NUM_VAR - 2)]	; rsp + 0
%define     nGuess      qword [rsp + VAR_SIZE * (NUM_VAR - 1)]  ; rsp + 8

;=============================== DEFINE MACRO ===============================
%macro      zero    1
    xor     %1, %1
%endmacro

;============================== CODE SECTION ================================
section	.text
global	main						    ; gcc linker expects main, not _start
extern initRandom, guessNumber, printf	; tell assembler/linker about externals

main:								; program starts here
	push	rbp						; set up stack frame
	mov		rbp, rsp				; set up stack frame - stack is aligned
    sub     rsp, NUM_VAR * VAR_SIZE	; make space for local variables

    call    initRandom
    mov     number, rax

top:
    call    guessNumber
    mov     nGuess, rax

    mov     rax, nGuess
    cmp     rax, number
    jl      tooLow
    jg      tooHigh
    jmp     justRight

tooLow:
    lea     rdi, [tooLowStr]
    zero    rax
    call    printf
    jmp     top

tooHigh:
    lea     rdi, [tooHighStr]
    zero    rax
    call    printf
    jmp     top

justRight:
    lea     rdi, [justRightStr]
    zero    rax
    call    printf

finish:
	xor		rax, rax				; EXIT_SUCCESS
	leave							; undo 1st 2 instructions in main
	ret								; return from main with retCode in rax


;=========================== READ-ONLY DATA SECTION =========================
section		.rodata
tooHighStr		db  LF, "Too high!",  LF, EOL
tooLowStr		db 	LF, "Too low!", LF, EOL
justRightStr	db	LF, "Just right!", LF,EOL

;============================================================================
