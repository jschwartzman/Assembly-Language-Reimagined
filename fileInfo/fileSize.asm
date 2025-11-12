;============================================================================
; fileSize.asm
; John Schwartzman, Forte Systems, Inc.
; 06/13/2024
; Linux x86_64
;============================================================================
%include	"macro.inc"

; global	    main
global		printFileSize

%define	NUM_RANGES	5
%define	DIVISOR		1000
%define PETABYTE	DIVISOR * DIVISOR * DIVISOR * DIVISOR * DIVISOR 
%define TERABYTE	DIVISOR * DIVISOR * DIVISOR * DIVISOR 
%define GIGABYTE	DIVISOR * DIVISOR * DIVISOR 
%define MEGABYTE	DIVISOR * DIVISOR 
%define KILOBYTE	DIVISOR 
%define BYTE		1

%define	NUM_VAR		4		; round up to next even value

;================== DEFINE LOCAL VARIABLES for printFileSize ================ =================
%define	nSize		qword [rsp + VAR_SIZE * (NUM_VAR - 4)]	; rsp +  0
%define	nDividend	qword [rsp + VAR_SIZE * (NUM_VAR - 3)]	; rsp +  8
%define	nTemp		qword [rsp + VAR_SIZE * (NUM_VAR - 2)]	; rsp +  16

;============================== CODE SECTION ================================
section	.text

printFileSize:
	prologue NUM_VAR

	mov		nSize, rdi
	mov		rax, nSize
	cmp		rax, DIVISOR
	jb		.belowDivisor

	mov		rax, [sizeArray]
	mov		nDividend, rax
	xor		rcx, rcx				; loop count - initialization for loop

.topOfLoop:
	mov		nDividend, rax			; if (nSize < nDivident) continue
	cmp		nSize, rax
	jb		.bottomOfLoop
	jmp		.proceed

.bottomOfLoop:
	inc		rcx						; increment loop count
	mov		rax, [sizeArray + 8 * rcx]
	mov		nDividend, rax
	jmp		.topOfLoop

.proceed:
	mod		nSize, nDividend		; is there a remainder?
	jz		.integerDivide			;	no remainder
	jmp		.nonIntegerDivide

.integerDivide:						; perform integer division
	mov		rax, nSize				; divide nSize / nMultiplicand
	mov		r8, nDividend
	cdqe							; sign extend rax into rdx
	div 	r8
	lea		rdi, [szModMultiplierZero]	; prepare to print result
	mov		rsi, rax				;  rax contains the quotient
	mov		dl,	byte [rangeArray + rcx]
	print
	jmp		.fin

.nonIntegerDivide:					; perform the floating point division
	movsd	xmm0, nSize
	movsd	xmm1, nDividend
	divsd	xmm0, xmm1				;qword nDividend
	lea		rdi, [szModMultiplierNotZero]
	; movsd	nTemp, xmm0
	zero	rdx
	mov		dl, byte [rangeArray + rcx]
	mov		rsi, rdx
	call	printsd
	jmp		.fin

.belowDivisor:
	lea		rdi, [szFmt]
	mov		rsi, nSize
	print

.fin:
	zero    eax                     ; return EXIT_SUCCESS

.exit:
	epilogue

;============================= LOCAL FUNCTION ===============================
printsd:							; print scalar double
	prologue

	mov		eax, ONE				; one floating point arg
	call    printf

	epilogue

;============================================================================

%ifdef __MAIN__	;============================================================

main:
	prologue
	
 	mov		rcx, -1

.runFileSize:
	inc		rcx
	push	rcx
	mov		rdi, [nFileSizes + 8 * rcx]
	cmp		rdi, 0xfedcba		; sentinal value
	je		.fin

	call	printFileSize
	pop		rcx
	jmp		.runFileSize

.fin:
	epilogue

%endif	;===================== __MAIN__ =====================================

;============================================================================
section     .data

nFileSize				dq	0
szFmt					db	"%lld ", EOL
szModMultiplierZero		db	"%lld.0%c ", EOL
szModMultiplierNotZero	db	"%.1f%c ", EOL

rangeArray	db		'P', 'T', 'G', 'M', 'K', 'B'

sizeArray	dq		PETABYTE, TERABYTE, GIGABYTE, MEGABYTE, KILOBYTE, BYTE

nFileSizes	dq		0, 		10,		100,	999,
			dq		1000, 	1121,   21000, 22007,
			dq		22107,	1250000, 135000000,
			dq		13500000000, 13500000000000,
			dq		0xfedcba

;============================================================================
