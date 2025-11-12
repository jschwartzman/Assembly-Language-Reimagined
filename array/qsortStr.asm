                                                              ;============================================================================
; quicksortStr.asm     - NOTE: elements to be sorted are strings.
; John Schwartzman, Forte Systems, Inc.
; 11/20/2023
; Linux x86_64
;
;============================================================================
%include "macro.inc"

global	qsortStr					; global procedures
extern	getElement, swapij			; external procedures
extern	array, pTempi, pTempj		; external data

%define nLow		qword [rsp +  0]	; for QuicksortStr
%define nHigh		qword [rsp +  8]
%define nPivot		qword [rsp + 16]
%define i			qword [rsp + 24]
%define	j			qword [rsp + 32]

;============================== CODE SECTION ================================
section	.text

;============================================================================
qsortStr:
	prologue 6
    mov		nLow, rdi
	mov		nPivot, rdi
	mov		nHigh, rsi				; nHigh = nRecords - 1

.firstIf:
	cmp		rdi, rsi
	jnl		.fin

	mov		nPivot, rdi				; nPivot = nLow
	mov		i, rdi					; i = nLow
	mov		j, rsi					; j = nHigh = nRecords - 1

.outerWhile:
	mov		rax, i
	cmp		rax, j
	jnl		.endOuterWhile

.while1:
	mov		rax, i
	cmp		rax, nHigh				; i < nHigh is 1st part of the AND condition
	jnl		.endWhile1

	mov		rcx, i
	lea		rdi, [pTempi]
	call	getElement

	mov		rcx, nPivot
	lea		rdi, [pTempj]
	call	getElement

	strcasecmp	[pTempi], [pTempj]		; pTempi <= pTempj is 2nd pard of the AND condition
	jle		.endWhile1

	inc		i
	jmp		.while1

.endWhile1:
.while2:
	mov		rcx, j
	lea		rdi, [pTempi]
	call	getElement

	mov		rcx, nPivot
	lea		rdi, [pTempj]
	call	getElement

	strcasecmp	[pTempi], [pTempj]		; this is the only test in while2
	jng		.endWhile2

	dec		j
	jmp		.while2

.endWhile2:
.secondIf:
	mov		rax, i
	cmp		rax, j
	jnl		.endSecondIf

	mov		r8, i
	mov		r9, j
	call	swapij
	jmp		.outerWhile

.endSecondIf:
.doSwap:
	mov 	r8, nPivot
	mov		r9, j
	call	swapij

.endOuterWhile:
.firstRecursion:
	mov		rdi, nLow
	mov		rsi, j
	dec		rsi
	call	qsortStr			; QuicksortStr(nLow, j - 1)

.secondRecursion:
	mov		rdi, j
	inc		rdi
	mov		rsi, nHigh
	call	qsortStr			; QuicksortStr(j + 1, nHigh)

.endFirstIf:
.fin:
	epilogue

;============================================================================
