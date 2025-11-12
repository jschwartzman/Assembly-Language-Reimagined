	.file	"fileType.c"			; compiled with -Og
	.intel_syntax noprefix
	.text
	.globl	setFilePath
	.type	setFilePath, @function
setFilePath:
	sub	rsp, 8
	mov	rsi, rdi
	mov	edi, OFFSET FLAT:filePath
	call	strcpy
	add	rsp, 8
	ret
	.size	setFilePath, .-setFilePath
	.globl	setFileName
	.type	setFileName, @function
setFileName:
	sub	rsp, 8
	mov	rsi, rdi
	mov	edi, OFFSET FLAT:fileName
	call	strcpy
	add	rsp, 8
	ret
	.size	setFileName, .-setFileName
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	" %ld %s %s "
.LC1:
	.string	"%5s"
.LC2:
	.string	" %b %d %H:%M"
.LC3:
	.string	"%s %s"
.LC4:
	.string	"readlink"
.LC5:
	.string	" -> %s*\n"
.LC6:
	.string	"*"
.LC7:
	.string	""
	.text
	.globl	printFileInfo
	.type	printFileInfo, @function
printFileInfo:
	push	rbp
	push	rbx
	sub	rsp, 184
	mov	rbp, rdi							; setFilePath arg
	call	setFilePath						; call setFilePath
	mov	esi, OFFSET FLAT:st					; st <- esi
	mov	rdi, rbp							; pFilePath
	call	lstat							; call lstat
	mov	ebx, DWORD PTR st[rip+24]
	and	ebx, 61440
	mov	edi, DWORD PTR st[rip+28]
	call	getpwuid
	movdqu	xmm0, XMMWORD PTR [rax]
	movaps	XMMWORD PTR pw[rip], xmm0
	movdqu	xmm1, XMMWORD PTR [rax+16]
	movaps	XMMWORD PTR pw[rip+16], xmm1
	movdqu	xmm2, XMMWORD PTR [rax+32]
	movaps	XMMWORD PTR pw[rip+32], xmm2
	mov	edi, DWORD PTR st[rip+32]
	call	getgrgid
	movdqu	xmm3, XMMWORD PTR [rax]
	movaps	XMMWORD PTR gr[rip], xmm3
	movdqu	xmm4, XMMWORD PTR [rax+16]
	movaps	XMMWORD PTR gr[rip+16], xmm4
	cmp	ebx, 32768
	je	.L39
	cmp	ebx, 16384
	je	.L40
	cmp	ebx, 40960
	je	.L41
	cmp	ebx, 4096
	je	.L42
	cmp	ebx, 49152
	je	.L43
	cmp	ebx, 24576
	je	.L44
	cmp	ebx, 8192
	jne	.L7
	mov	BYTE PTR filePerm[rip], 99
	jmp	.L7
.L39:
	mov	BYTE PTR filePerm[rip], 45
.L7:
	mov	eax, DWORD PTR st[rip+24]
	test	ah, 1
	je	.L13
	mov	BYTE PTR filePerm[rip+1], 114
.L14:
	test	al, -128
	je	.L15
	mov	BYTE PTR filePerm[rip+2], 119
.L16:
	test	al, 64
	je	.L17
	mov	BYTE PTR filePerm[rip+3], 120
.L18:
	test	al, 32
	je	.L19
	mov	BYTE PTR filePerm[rip+4], 114
.L20:
	test	al, 16
	je	.L21
	mov	BYTE PTR filePerm[rip+5], 119
.L22:
	test	al, 8
	je	.L23
	mov	BYTE PTR filePerm[rip+6], 120
.L24:
	test	al, 4
	je	.L25
	mov	BYTE PTR filePerm[rip+7], 114
.L26:
	test	al, 2
	je	.L27
	mov	BYTE PTR filePerm[rip+8], 119
.L28:
	test	al, 1
	je	.L29
	mov	BYTE PTR filePerm[rip+9], 120
.L31:
	mov	ebx, 0
	jmp	.L30
.L40:
	mov	BYTE PTR filePerm[rip], 100
	jmp	.L7
.L41:
	mov	BYTE PTR filePerm[rip], 108
	jmp	.L7
.L42:
	mov	BYTE PTR filePerm[rip], 112
	jmp	.L7
.L43:
	mov	BYTE PTR filePerm[rip], 115
	jmp	.L7
.L44:
	mov	BYTE PTR filePerm[rip], 98
	jmp	.L7
.L13:
	mov	BYTE PTR filePerm[rip+1], 45
	jmp	.L14
.L15:
	mov	BYTE PTR filePerm[rip+2], 45
	jmp	.L16
.L17:
	mov	BYTE PTR filePerm[rip+3], 45
	jmp	.L18
.L19:
	mov	BYTE PTR filePerm[rip+4], 45
	jmp	.L20
.L21:
	mov	BYTE PTR filePerm[rip+5], 45
	jmp	.L22
.L23:
	mov	BYTE PTR filePerm[rip+6], 45
	jmp	.L24
.L25:
	mov	BYTE PTR filePerm[rip+7], 45
	jmp	.L26
.L27:
	mov	BYTE PTR filePerm[rip+8], 45
	jmp	.L28
.L29:
	mov	BYTE PTR filePerm[rip+9], 45
	jmp	.L31
.L32:
	movsx	rax, ebx
	movsx	edi, BYTE PTR filePerm[rax]
	call	putchar
	add	ebx, 1
.L30:
	cmp	ebx, 9
	jle	.L32
	mov	rcx, QWORD PTR gr[rip]
	mov	rdx, QWORD PTR pw[rip]
	mov	rsi, QWORD PTR st[rip+16]
	mov	edi, OFFSET FLAT:.LC0
	mov	eax, 0
	call	printf
	mov	rdi, QWORD PTR st[rip+48]
	call	calculateSize
	mov	rsi, rax
	mov	edi, OFFSET FLAT:.LC1
	mov	eax, 0
	call	printf
	mov	edi, OFFSET FLAT:st+88
	call	localtime
	mov	rcx, rax
	mov	edx, OFFSET FLAT:.LC2
	mov	esi, 40
	lea	rdi, [rsp+128]
	call	strftime
	mov	edx, OFFSET FLAT:fileName
	lea	rsi, [rsp+128]
	mov	edi, OFFSET FLAT:.LC3
	mov	eax, 0
	call	printf
	cmp	BYTE PTR filePerm[rip], 108
	je	.L45
	test	BYTE PTR st[rip+24], 64
	jne	.L46
	mov	edi, OFFSET FLAT:.LC7
	call	puts
.L5:
	add	rsp, 184
	pop	rbx
	pop	rbp
	ret
.L45:
	mov	edx, 128
	mov	rsi, rsp
	mov	rdi, rbp
	call	readlink
	cmp	rax, -1
	je	.L47
	mov	rsi, rsp
	mov	edi, OFFSET FLAT:.LC5
	mov	eax, 0
	call	printf
	jmp	.L5
.L47:
	mov	edi, OFFSET FLAT:.LC4
	call	perror
	jmp	.L5
.L46:
	mov	edi, OFFSET FLAT:.LC6
	call	puts
	jmp	.L5
	.size	printFileInfo, .-printFileInfo
	.globl	gr
	.bss
	.align 32
	.type	gr, @object
	.size	gr, 32
gr:
	.zero	32
	.globl	pw
	.align 32
	.type	pw, @object
	.size	pw, 48
pw:
	.zero	48
	.globl	st
	.align 32
	.type	st, @object
	.size	st, 144
st:
	.zero	144
	.globl	filePerm
	.align 8
	.type	filePerm, @object
	.size	filePerm, 10
filePerm:
	.zero	10
	.globl	pFileType
	.align 8
	.type	pFileType, @object
	.size	pFileType, 8
pFileType:
	.zero	8
	.globl	filePath
	.align 32
	.type	filePath, @object
	.size	filePath, 128
filePath:
	.zero	128
	.globl	fileName
	.align 32
	.type	fileName, @object
	.size	fileName, 64
fileName:
	.zero	64
	.ident	"GCC: (SUSE Linux) 13.2.1 20240206 [revision 67ac78caf31f7cb3202177e6428a46d829b70f23]"
	.section	.note.GNU-stack,"",@progbits
