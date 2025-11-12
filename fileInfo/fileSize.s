	.file	"fileSize.c"
	.intel_syntax noprefix
	.text
	.section	.rodata
	.type	sizes, @object
	.size	sizes, 6
sizes:
	.ascii	"EPTGMK"
	.align 32
	.type	range, @object
	.size	range, 56
range:
	.quad	1000000000000001000
	.quad	1000000000000000000
	.quad	1000000000000000
	.quad	1000000000000
	.quad	1000000000
	.quad	1000000
	.quad	1000
.LC0:
	.string	"%lld\n"
.LC1:
	.string	"%lld.0%c\n"
.LC2:
	.string	"%.1f%c\n"
	.text
	.globl	printFileSize
	.type	printFileSize, @function
printFileSize:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 48
	mov	QWORD PTR [rbp-40], rdi
	cmp	QWORD PTR [rbp-40], 999
	ja	.L2
	mov	rax, QWORD PTR [rbp-40]
	mov	rsi, rax
	mov	edi, OFFSET FLAT:.LC0
	mov	eax, 0
	call	printf
	jmp	.L1
.L2:
	mov	DWORD PTR [rbp-4], 0
	jmp	.L4
.L12:
	mov	eax, DWORD PTR [rbp-4]
	cdqe
	mov	rax, QWORD PTR range[0+rax*8]
	mov	QWORD PTR [rbp-16], rax
	mov	rax, QWORD PTR [rbp-40]
	cmp	rax, QWORD PTR [rbp-16]
	jb	.L14
	mov	rax, QWORD PTR [rbp-40]
	mov	edx, 0
	div	QWORD PTR [rbp-16]
	mov	QWORD PTR [rbp-24], rdx
	cmp	QWORD PTR [rbp-24], 0
	jne	.L7
	mov	rax, QWORD PTR [rbp-40]
	mov	edx, 0
	div	QWORD PTR [rbp-16]
	mov	QWORD PTR [rbp-24], rax
	mov	eax, DWORD PTR [rbp-4]
	sub	eax, 1
	cdqe
	movzx	eax, BYTE PTR sizes[rax]
	movsx	edx, al
	mov	rax, QWORD PTR [rbp-24]
	mov	rsi, rax
	mov	edi, OFFSET FLAT:.LC1
	mov	eax, 0
	call	printf
	jmp	.L1
.L7:
	mov	rax, QWORD PTR [rbp-40]
	test	rax, rax
	js	.L8
	pxor	xmm0, xmm0
	cvtsi2ss	xmm0, rax
	jmp	.L9
.L8:
	mov	rdx, rax
	shr	rdx
	and	eax, 1
	or	rdx, rax
	pxor	xmm0, xmm0
	cvtsi2ss	xmm0, rdx
	addss	xmm0, xmm0
.L9:
	mov	rax, QWORD PTR [rbp-16]
	test	rax, rax
	js	.L10
	pxor	xmm1, xmm1
	cvtsi2ss	xmm1, rax
	jmp	.L11
.L10:
	mov	rdx, rax
	shr	rdx
	and	eax, 1
	or	rdx, rax
	pxor	xmm1, xmm1
	cvtsi2ss	xmm1, rdx
	addss	xmm1, xmm1
.L11:
	divss	xmm0, xmm1
	movss	DWORD PTR [rbp-28], xmm0
	mov	eax, DWORD PTR [rbp-4]
	sub	eax, 1
	cdqe
	movzx	eax, BYTE PTR sizes[rax]
	movsx	edx, al
	pxor	xmm2, xmm2
	cvtss2sd	xmm2, DWORD PTR [rbp-28]
	movq	rax, xmm2
	mov	esi, edx
	movq	xmm0, rax
	mov	edi, OFFSET FLAT:.LC2
	mov	eax, 1
	call	printf
	jmp	.L1
.L14:
	nop
	add	DWORD PTR [rbp-4], 1
.L4:
	cmp	DWORD PTR [rbp-4], 6
	jle	.L12
.L1:
	leave
	ret
	.size	printFileSize, .-printFileSize
	.ident	"GCC: (SUSE Linux) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
