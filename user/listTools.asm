;============================================================================
; listTools.asm
; John Schwartzman, Forte Systems, Inc.
; 11/27/2023
; Linux x86_64
;
;============================================================================
ELEMENT_SIZE	equ		64

%include "macro.inc"

global	getElement, putElement, swapij
extern	QuicksortStr, BubblesortStr		; external procedures
global	node, node_size
global	printElement
global	listIndex
global	array, pTemp, pTempi, pTempj	; exported data
global	createHeadNode, insertNode
global	traverseList, freeList

%define	nRecords 	qword [rsp + 0]	; for traverseList

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
getElement:							; rcx = index, rsi = src, rdi = dest
	mov		rsi, [listIndex + 8 * rcx]
	lea		rsi, [rsi + nName]
	push	rcx
	strcpy
	pop		rcx
	ret								; rdi contains array[rcx] on return

;============================================================================
putElement:							; rcx = index, rsi = src, rdi = dest
	mov		rdi, [listIndex + 8 * rcx]
	lea		rdi, [rdi + nName]
	push	rcx
	strcpy
	pop		rcx
	ret								; rdi contains array[rcx] on return

;============================================================================
printElement:							; rcx = index
	imul	rcx
	lea		rsi, [listIndex + 8 * rcx]	; rsi => element
	push	rcx
	print	[listFmt]
	pop		rcx
	ret

;============================================================================
freeList:
	lea		rax, [headNode]
	lea		rax, [rax + nNext]

.top:
	push	rax
	free	[eax]						; free the node
	pop		rax
	lea		rax, [rax + nNext]
	cmp		rax, [headNode]
	je		.fin
	jmp		.top

.fin:
	free	[eax]						; free headNode
	ret

;============================================================================
createHeadNode:
	malloc	node_size				; node_size is defined by struc node
	jz		.fin

	mov		[rax + nPrev], eax		; head points back to itself
	mov		[rax + nNext], eax		; head points forward to itself
	mov		[headNode], eax

.fin:	
	ret

;============================================================================
insertNode:
	prologue 2
	push	rsi						; save 
	push	rcx						; save insertion index

	malloc	node_size				; rax => allocation
	jz		.fin

	pop		rcx
	mov		[listIndex + 8 * rcx], eax	; save allocation in listindex[]

	pop		rsi						; get nodeNameT
	lea		rdi, [eax + nName]		; dest
	push	rax
	strcpy
	pop		rax

	; housekeeping - insert new node at head's->next
	lea		rcx, [headNode]			; get head node
	mov		[rax + nPrev], rcx		; new node prev = head

	lea		rcx, [rcx + nNext]		; rcx = head=>next
	mov		[rax + nNext], rcx		; new node next = head->next

	lea		rcx, [headNode]
	mov		[rcx + nNext], rax		; head->next = new node
									; do not change head->prev
.fin:
	epilogue

;============================================================================
traverseList:					; retrieve the nodes the way they're sorted
	prologue 2					; and not the way they're inserted
	mov		nRecords, rdi
	zero	rcx

.top:
	cmp		rcx, nRecords
	je		.fin

	mov		rsi, [listIndex + 8 * rcx]	; use listIndex to get sorted list
	push	rcx
	print	[listFmt]
	pop		rcx
	inc		rcx
	jmp		.top

.fin:
	epilogue

;=========================== READ-ONLY DATA SECTION =========================
section	.rodata
listFmt		db  TAB, "%s", LF, EOL
prtInsTotal	db	TAB, LF, "%d elements were loaded.", LF, EOL
;============================================================================
section	.bss
pTemp		times ELEMENT_SIZE	db 0
pTempi		times ELEMENT_SIZE	db 0
pTempj		times ELEMENT_SIZE	db 0
headNode    resb 	node_size		; automatically generated
listIndex   resq    256             ; max number of linked list elements

   STRUC   node
nName		resb    64
nType		resb	 1
nPrev   	resq     1
nNext   	resq     1
		align 8
    ENDSTRUC

;============================================================================