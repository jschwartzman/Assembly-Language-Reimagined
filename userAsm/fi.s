	.file	"fi.c"
	.intel_syntax noprefix
	.text
	.section	.rodata
.LC0:
	.string	"FilePath: %s\n"
.LC1:
	.string	"uid: %d, gid: %d\n"
.LC2:
	.string	"File Size: %d"
	.text
	.globl	printFileInfo
	.type	printFileInfo, @function
printFileInfo:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 176
	mov	QWORD PTR [rbp-168], rdi
	lea	rdx, [rbp-160]
	mov	rax, QWORD PTR [rbp-168]
	mov	rsi, rdx
	mov	rdi, rax
	call	lstat
	mov	DWORD PTR [rbp-4], eax
	cmp	DWORD PTR [rbp-4], 0
	je	.L2
	mov	eax, DWORD PTR [rbp-4]
	jmp	.L4
.L2:
	mov	rax, QWORD PTR [rbp-168]
	mov	rsi, rax
	mov	edi, OFFSET FLAT:.LC0
	mov	eax, 0
	call	printf
	mov	edx, DWORD PTR [rbp-128]
	mov	eax, DWORD PTR [rbp-132]
	mov	esi, eax
	mov	edi, OFFSET FLAT:.LC1
	mov	eax, 0
	call	printf
	mov	rax, QWORD PTR [rbp-112]
	mov	rsi, rax
	mov	edi, OFFSET FLAT:.LC2
	mov	eax, 0
	call	printf
	mov	eax, 0
.L4:
	leave
	ret
	.size	printFileInfo, .-printFileInfo
	.section	.rodata
	.align 8
.LC3:
	.string	"/home/js/Development/asm_x86_64/userAsm/fi.c"
	.text
	.globl	main
	.type	main, @function
main:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 16
	mov	QWORD PTR [rbp-8], OFFSET FLAT:.LC3
	mov	rax, QWORD PTR [rbp-8]
	mov	rdi, rax
	call	printFileInfo
	leave
	ret
	.size	main, .-main
	.ident	"GCC: (SUSE Linux) 13.2.1 20240206 [revision 67ac78caf31f7cb3202177e6428a46d829b70f23]"
	.section	.note.GNU-stack,"",@progbits
