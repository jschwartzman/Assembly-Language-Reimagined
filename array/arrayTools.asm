;============================================================================
; arrayTools.asm	- for sorting strings
; John Schwartzman, Forte Systems, Inc.
; 11/26/2023
; Linux x86_64
;
;============================================================================
ARRAY_SIZE			equ 4096
ELEMENT_SIZE		equ	  64

%include "macro.inc"

extern	qsortPartStr, BubblesortStr		; external procedures
global	getElement, putElement, swap
global	displayArray
global	array, pTempi, pTempj, pPivot	; exported data

%define nRecords	qword [rsp + 0]		; for displayArray

;============================================================================
swap:								; r8 and r9 contain the indexes to swap
	prologue

	lea		rdi, [pTemp]
	mov		rcx, r8
	call	getElement				
	strcpy							; pTemp <- array[r8]

	mov		rax, ELEMENT_SIZE
	imul	r9
	lea		rdi, [array + rax]		; rdi <- array[r9]

	swapreg	rdi, rsi				; rdi <-> rsi
	strcpy							; array[r9] <- array[r8]

	lea		rsi, [pTemp]
	mov		rcx, r9
	call	putElement				; array[r8] <- pTemp

 	epilogue

;============================================================================
getElement:							; rcx = index, returns element in rdi
	prologue
	mov		rax, ELEMENT_SIZE
	imul	rcx
	lea		rsi, [rax + array]
	push	rcx
	strcpy
	pop		rcx
	epilogue						; rdi contains array[rcx] on return

;============================================================================
putElement:							; rcx = index, rsi = src, rdi = dest
	prologue
	mov		rax, ELEMENT_SIZE
	imul	rcx
	lea		rdi, [rax + array]
	push	rcx
	strcpy
	pop		rcx
	epilogue

;============================================================================
displayArray:
	prologue 2
	mov		nRecords, rdi			; get nElements to display
	zero	rcx						; rcx is nIndex = 0

.top
	lea		rdi, [pTemp]
	call	getElement
	push	rcx
	print2Str	[arrayFmt], [pTemp]
	pop		rcx
	inc		rcx
	cmp		rcx, nRecords
	jle		.top					; stop at nRecords - 1

	epilogue

;=========================== READ-ONLY DATA SECTION =========================
section	.rodata
arrayFmt	db  TAB, "%s", LF, EOL
prtInsTotal	db	TAB, LF, "%d elements were loaded.", LF, EOL
SRC_STR10	db	"Warner the Brother #1", EOL
;================================ DATA SECTION ==============================
section .bss
array			resb	ARRAY_SIZE
;============================================================================
section	.data
pTemp		times ELEMENT_SIZE	db 0
pTempi		times ELEMENT_SIZE	db 0
pTempj		times ELEMENT_SIZE	db 0
pPivot		times ELEMENT_SIZE	db 0
;============================================================================