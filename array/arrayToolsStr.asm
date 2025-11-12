;============================================================================
; arrayToolsStr.asm	- for sorting strings
; John Schwartzman, Forte Systems, Inc.
; 11/26/2023
; Linux x86_64
;
;============================================================================
ARRAY_SIZE			equ 4096
ELEMENT_SIZE		equ	  64

%include "macro.inc"

global	getElement, putElement, swapij
global	displayArray
global	array, pTemp, pTempi, pTempj	; exported data
global	arrayFmt, prtInsTotal
%define nRecords	qword [rsp + 0]		; for displayArray

;============================================================================
swapij:
	mov		rcx, r8
	lea		rdi, [pTempi]			; temp holding var
	call	getElement				; pTempi contains str from array[i]

	mov		rcx, r9
	lea		rdi, [pTempj]			; temp holding var
	call	getElement				; pTempj contains str from array[j]
	
	mov		rcx, r8
	lea		rsi, [pTempj]
	call	putElement				; rdi contains str from array[j]

	mov		rcx, r9
	lea		rsi, [pTempi]
	call	putElement				; rdi contains str from array[i]

 	ret

;============================================================================
getElement:							; rcx = index, returns element in rsi
	mov		rax, ELEMENT_SIZE
	imul	rcx
	lea		rsi, [rax + array]
	push	rcx
	strcpy
	pop		rcx
	ret								; rsi contains array[rcx] on return

;============================================================================
putElement:							; rcx = index, rsi = int, rdi = dest
	prologue
	mov		rax, ELEMENT_SIZE
	nop
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
;================================ DATA SECTION ==============================
section .bss
pTemp		times ELEMENT_SIZE	db 0
pTempi		times ELEMENT_SIZE	db 0
pTempj		times ELEMENT_SIZE	db 0
array		resb	ARRAY_SIZE
;============================================================================
