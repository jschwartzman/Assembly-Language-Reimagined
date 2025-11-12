	.file	"fileInfo.c"
	.intel_syntax noprefix
	.text
	.globl	st
	.bss
	.align 32
	.type	st, @object
	.size	st, 144
st:
	.zero	144
	.globl	pw
	.align 8
	.type	pw, @object
	.size	pw, 8
pw:
	.zero	8
	.globl	gr
	.align 8
	.type	gr, @object
	.size	gr, 8
gr:
	.zero	8
	.globl	pFileName
	.section	.rodata
.LC0:
	.string	"goldfish"
	.data
	.align 8
	.type	pFileName, @object
	.size	pFileName, 8
pFileName:
	.quad	.LC0
	.globl	pFilePath
	.section	.rodata
	.align 8
.LC1:
	.string	"/home/js/Development/asm_x86_64/user/files/goldfish"
	.data
	.align 8
	.type	pFilePath, @object
	.size	pFilePath, 8
pFilePath:
	.quad	.LC1
	.globl	filePerm
	.bss
	.align 8
	.type	filePerm, @object
	.size	filePerm, 11
filePerm:
	.zero	11
	.section	.rodata
.LC2:
	.string	"File: %s\n"
.LC3:
	.string	"uid: %d gid:%d\n"
.LC4:
	.string	"uid str: %s gid str: %s\n"
.LC5:
	.string	"hard links: %ld\n"
.LC6:
	.string	"Permissions: %s\n"
.LC7:
	.string	"File size: %ld\n"
	.align 8
.LC8:
	.string	"st: %ld, %ld, %ld, %ld, %ld, %ld, %ld, %ld, %ld, %ld, "
.LC9:
	.string	"%ld, %ld, %ld\n"
.LC10:
	.string	"st_size: %ld\n"
	.align 8
.LC11:
	.string	"Pointers: %p, %p, %p, %p, %p %p\n"
	.text
	.globl	printFileInfo
	.type	printFileInfo, @function
printFileInfo:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 16
	mov	rax, QWORD PTR pFilePath[rip]
	mov	esi, OFFSET FLAT:st
	mov	rdi, rax
	call	lstat
	test	eax, eax
	jne	.L29
	mov	eax, DWORD PTR st[rip+28]
	mov	edi, eax
	call	getpwuid
	mov	QWORD PTR pw[rip], rax
	mov	eax, DWORD PTR st[rip+32]
	mov	edi, eax
	call	getgrgid
	mov	QWORD PTR gr[rip], rax
	mov	eax, DWORD PTR st[rip+24]
	and	eax, 61440
	mov	DWORD PTR [rbp-4], eax
	cmp	DWORD PTR [rbp-4], 32768
	jne	.L4
	mov	BYTE PTR filePerm[rip], 45
	jmp	.L5
.L4:
	cmp	DWORD PTR [rbp-4], 16384
	jne	.L6
	mov	BYTE PTR filePerm[rip], 100
	jmp	.L5
.L6:
	cmp	DWORD PTR [rbp-4], 40960
	jne	.L7
	mov	BYTE PTR filePerm[rip], 108
	jmp	.L5
.L7:
	cmp	DWORD PTR [rbp-4], 4096
	jne	.L8
	mov	BYTE PTR filePerm[rip], 112
	jmp	.L5
.L8:
	cmp	DWORD PTR [rbp-4], 49152
	jne	.L9
	mov	BYTE PTR filePerm[rip], 115
	jmp	.L5
.L9:
	cmp	DWORD PTR [rbp-4], 24576
	jne	.L10
	mov	BYTE PTR filePerm[rip], 98
	jmp	.L5
.L10:
	cmp	DWORD PTR [rbp-4], 8192
	jne	.L5
	mov	BYTE PTR filePerm[rip], 99
.L5:
	mov	eax, DWORD PTR st[rip+24]
	and	eax, 256
	test	eax, eax
	je	.L11
	mov	BYTE PTR filePerm[rip+1], 114
	jmp	.L12
.L11:
	mov	BYTE PTR filePerm[rip+1], 45
.L12:
	mov	eax, DWORD PTR st[rip+24]
	and	eax, 128
	test	eax, eax
	je	.L13
	mov	BYTE PTR filePerm[rip+2], 119
	jmp	.L14
.L13:
	mov	BYTE PTR filePerm[rip+2], 45
.L14:
	mov	eax, DWORD PTR st[rip+24]
	and	eax, 64
	test	eax, eax
	je	.L15
	mov	BYTE PTR filePerm[rip+3], 120
	jmp	.L16
.L15:
	mov	BYTE PTR filePerm[rip+3], 45
.L16:
	mov	eax, DWORD PTR st[rip+24]
	and	eax, 32
	test	eax, eax
	je	.L17
	mov	BYTE PTR filePerm[rip+4], 114
	jmp	.L18
.L17:
	mov	BYTE PTR filePerm[rip+4], 45
.L18:
	mov	eax, DWORD PTR st[rip+24]
	and	eax, 16
	test	eax, eax
	je	.L19
	mov	BYTE PTR filePerm[rip+5], 119
	jmp	.L20
.L19:
	mov	BYTE PTR filePerm[rip+5], 45
.L20:
	mov	eax, DWORD PTR st[rip+24]
	and	eax, 8
	test	eax, eax
	je	.L21
	mov	BYTE PTR filePerm[rip+6], 120
	jmp	.L22
.L21:
	mov	BYTE PTR filePerm[rip+6], 45
.L22:
	mov	eax, DWORD PTR st[rip+24]
	and	eax, 4
	test	eax, eax
	je	.L23
	mov	BYTE PTR filePerm[rip+7], 114
	jmp	.L24
.L23:
	mov	BYTE PTR filePerm[rip+7], 45
.L24:
	mov	eax, DWORD PTR st[rip+24]
	and	eax, 2
	test	eax, eax
	je	.L25
	mov	BYTE PTR filePerm[rip+8], 119
	jmp	.L26
.L25:
	mov	BYTE PTR filePerm[rip+8], 45
.L26:
	mov	eax, DWORD PTR st[rip+24]
	and	eax, 1
	test	eax, eax
	je	.L27
	mov	BYTE PTR filePerm[rip+9], 120
	jmp	.L28
.L27:
	mov	BYTE PTR filePerm[rip+9], 45
.L28:
	mov	BYTE PTR filePerm[rip+10], 0
	mov	rax, QWORD PTR pFileName[rip]
	mov	rsi, rax
	mov	edi, OFFSET FLAT:.LC2
	mov	eax, 0
	call	printf
	mov	edx, DWORD PTR st[rip+32]
	mov	eax, DWORD PTR st[rip+28]
	mov	esi, eax
	mov	edi, OFFSET FLAT:.LC3
	mov	eax, 0
	call	printf
	mov	rax, QWORD PTR gr[rip]
	mov	rdx, QWORD PTR [rax]
	mov	rax, QWORD PTR pw[rip]
	mov	rax, QWORD PTR [rax]
	mov	rsi, rax
	mov	edi, OFFSET FLAT:.LC4
	mov	eax, 0
	call	printf
	mov	rax, QWORD PTR st[rip+16]
	mov	rsi, rax
	mov	edi, OFFSET FLAT:.LC5
	mov	eax, 0
	call	printf
	mov	esi, OFFSET FLAT:filePerm
	mov	edi, OFFSET FLAT:.LC6
	mov	eax, 0
	call	printf
	mov	rax, QWORD PTR st[rip+48]
	mov	rsi, rax
	mov	edi, OFFSET FLAT:.LC7
	mov	eax, 0
	call	printf
	sub	rsp, 8
	push	8
	push	8
	push	8
	push	8
	push	4
	mov	r9d, 4
	mov	r8d, 8
	mov	ecx, 4
	mov	edx, 8
	mov	esi, 8
	mov	edi, OFFSET FLAT:.LC8
	mov	eax, 0
	call	printf
	add	rsp, 48
	mov	ecx, 8
	mov	edx, 8
	mov	esi, 8
	mov	edi, OFFSET FLAT:.LC9
	mov	eax, 0
	call	printf
	mov	esi, 144
	mov	edi, OFFSET FLAT:.LC10
	mov	eax, 0
	call	printf
	sub	rsp, 8
	push	OFFSET FLAT:st+32
	mov	r9d, OFFSET FLAT:st+28
	mov	r8d, OFFSET FLAT:st+16
	mov	ecx, OFFSET FLAT:st+24
	mov	edx, OFFSET FLAT:st+8
	mov	esi, OFFSET FLAT:st
	mov	edi, OFFSET FLAT:.LC11
	mov	eax, 0
	call	printf
	add	rsp, 16
	jmp	.L1
.L29:
	nop
.L1:
	leave
	ret
	.size	printFileInfo, .-printFileInfo
	.globl	main
	.type	main, @function
main:
	push	rbp
	mov	rbp, rsp
	mov	eax, 0
	call	printFileInfo
	mov	eax, 0
	pop	rbp
	ret
	.size	main, .-main
	.ident	"GCC: (SUSE Linux) 13.2.1 20240206 [revision 67ac78caf31f7cb3202177e6428a46d829b70f23]"
	.section	.note.GNU-stack,"",@progbits
