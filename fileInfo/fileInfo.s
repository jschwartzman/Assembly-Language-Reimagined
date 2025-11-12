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
	.globl	pFilePath
	.section	.rodata
.LC0:
	.string	"fi.asm"
	.data
	.align 8
	.type	pFilePath, @object
	.size	pFilePath, 8
pFilePath:
	.quad	.LC0
	.globl	filePerm
	.align 8
	.type	filePerm, @object
	.size	filePerm, 11
filePerm:
	.string	"----------"
	.section	.rodata
.LC1:
	.string	"%c"
.LC2:
	.string	"aTime = %s\n"
	.text
	.globl	printFileAppDateTime
	.type	printFileAppDateTime, @function
printFileAppDateTime:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 64
	mov	QWORD PTR [rbp-56], rdi
	lea	rax, [rbp-56]
	mov	rdi, rax
	call	localtime
	mov	QWORD PTR [rbp-8], rax
	mov	rdx, QWORD PTR [rbp-8]
	lea	rax, [rbp-48]
	mov	rcx, rdx
	mov	edx, OFFSET FLAT:.LC1
	mov	esi, 28
	mov	rdi, rax
	call	strftime
	mov	DWORD PTR [rbp-12], eax
	cmp	DWORD PTR [rbp-12], 0
	jne	.L2
	mov	eax, -1
	jmp	.L4
.L2:
	lea	rax, [rbp-48]
	mov	rsi, rax
	mov	edi, OFFSET FLAT:.LC2
	mov	eax, 0
	call	printf
	mov	eax, 0
.L4:
	leave
	ret
	.size	printFileAppDateTime, .-printFileAppDateTime
	.section	.rodata
.LC3:
	.string	"uid: %d, gid: %d\n"
.LC4:
	.string	"mode: %o (octal)\n"
.LC5:
	.string	"uid: %s, gid: %s\n"
.LC6:
	.string	"File: %s\n"
.LC7:
	.string	"hard links: %ld\n"
.LC8:
	.string	"Permissions: %s\n"
.LC9:
	.string	"File size: %ld\n"
.LC10:
	.string	"st_dev:     %ld\n"
.LC11:
	.string	"st_ino:     %ld\n"
.LC12:
	.string	"st_mode:    %ld\n"
.LC13:
	.string	"st_nlink:   %ld\n"
.LC14:
	.string	"st_uid:     %ld\n"
.LC15:
	.string	"st_gid:     %ld\n"
.LC16:
	.string	"st_rdev:    %ld\n"
.LC17:
	.string	"st_size:    %ld\n"
.LC18:
	.string	"st_blksize: %ld\n"
.LC19:
	.string	"st_blocks:  %ld\n"
.LC20:
	.string	"st_atime:   %ld\n"
.LC21:
	.string	"st_mtime:   %ld\n"
.LC22:
	.string	"st_ctime:   %ld\n"
.LC23:
	.string	"pw_name:    %ld\n"
.LC24:
	.string	"pw_passwd:  %ld\n"
.LC25:
	.string	"pw_uid:    \t%ld\n"
.LC26:
	.string	"pw_gid:    \t%ld\n"
.LC27:
	.string	"pw_gecos:  \t%ld\n"
.LC28:
	.string	"pw_dir:    \t%ld\n"
.LC29:
	.string	"pw_shell   \t%ld\n"
.LC30:
	.string	"gw_name:    %ld\n"
.LC31:
	.string	"gw_passwd:  %ld\n"
.LC32:
	.string	"gr_gid:     %ld\n"
.LC33:
	.string	"gr_mem:     %ld\n"
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
	mov	DWORD PTR [rbp-4], eax
	cmp	DWORD PTR [rbp-4], 0
	je	.L6
	mov	eax, DWORD PTR [rbp-4]
	jmp	.L7
.L6:
	mov	edx, DWORD PTR st[rip+32]
	mov	eax, DWORD PTR st[rip+28]
	mov	esi, eax
	mov	edi, OFFSET FLAT:.LC3
	mov	eax, 0
	call	printf
	mov	eax, DWORD PTR st[rip+24]
	mov	esi, eax
	mov	edi, OFFSET FLAT:.LC4
	mov	eax, 0
	call	printf
	mov	eax, DWORD PTR st[rip+28]
	mov	edi, eax
	call	getpwuid
	mov	QWORD PTR pw[rip], rax
	mov	eax, DWORD PTR st[rip+32]
	mov	edi, eax
	call	getgrgid
	mov	QWORD PTR gr[rip], rax
	mov	rax, QWORD PTR gr[rip]
	mov	rdx, QWORD PTR [rax]
	mov	rax, QWORD PTR pw[rip]
	mov	rax, QWORD PTR [rax]
	mov	rsi, rax
	mov	edi, OFFSET FLAT:.LC5
	mov	eax, 0
	call	printf
	mov	eax, DWORD PTR st[rip+24]
	and	eax, 61440
	mov	DWORD PTR [rbp-8], eax
	cmp	DWORD PTR [rbp-8], 32768
	jne	.L8
	mov	BYTE PTR filePerm[rip], 45
	jmp	.L9
.L8:
	cmp	DWORD PTR [rbp-8], 16384
	jne	.L10
	mov	BYTE PTR filePerm[rip], 100
	jmp	.L9
.L10:
	cmp	DWORD PTR [rbp-8], 40960
	jne	.L11
	mov	BYTE PTR filePerm[rip], 108
	jmp	.L9
.L11:
	cmp	DWORD PTR [rbp-8], 4096
	jne	.L12
	mov	BYTE PTR filePerm[rip], 112
	jmp	.L9
.L12:
	cmp	DWORD PTR [rbp-8], 49152
	jne	.L13
	mov	BYTE PTR filePerm[rip], 115
	jmp	.L9
.L13:
	cmp	DWORD PTR [rbp-8], 24576
	jne	.L14
	mov	BYTE PTR filePerm[rip], 98
	jmp	.L9
.L14:
	cmp	DWORD PTR [rbp-8], 8192
	jne	.L9
	mov	BYTE PTR filePerm[rip], 99
.L9:
	mov	eax, DWORD PTR st[rip+24]
	and	eax, 256
	test	eax, eax
	je	.L15
	mov	BYTE PTR filePerm[rip+1], 114
	jmp	.L16
.L15:
	mov	BYTE PTR filePerm[rip+1], 45
.L16:
	mov	eax, DWORD PTR st[rip+24]
	and	eax, 128
	test	eax, eax
	je	.L17
	mov	BYTE PTR filePerm[rip+2], 119
	jmp	.L18
.L17:
	mov	BYTE PTR filePerm[rip+2], 45
.L18:
	mov	eax, DWORD PTR st[rip+24]
	and	eax, 64
	test	eax, eax
	je	.L19
	mov	BYTE PTR filePerm[rip+3], 120
	jmp	.L20
.L19:
	mov	BYTE PTR filePerm[rip+3], 45
.L20:
	mov	eax, DWORD PTR st[rip+24]
	and	eax, 32
	test	eax, eax
	je	.L21
	mov	BYTE PTR filePerm[rip+4], 114
	jmp	.L22
.L21:
	mov	BYTE PTR filePerm[rip+4], 45
.L22:
	mov	eax, DWORD PTR st[rip+24]
	and	eax, 16
	test	eax, eax
	je	.L23
	mov	BYTE PTR filePerm[rip+5], 119
	jmp	.L24
.L23:
	mov	BYTE PTR filePerm[rip+5], 45
.L24:
	mov	eax, DWORD PTR st[rip+24]
	and	eax, 8
	test	eax, eax
	je	.L25
	mov	BYTE PTR filePerm[rip+6], 120
	jmp	.L26
.L25:
	mov	BYTE PTR filePerm[rip+6], 45
.L26:
	mov	eax, DWORD PTR st[rip+24]
	and	eax, 4
	test	eax, eax
	je	.L27
	mov	BYTE PTR filePerm[rip+7], 114
	jmp	.L28
.L27:
	mov	BYTE PTR filePerm[rip+7], 45
.L28:
	mov	eax, DWORD PTR st[rip+24]
	and	eax, 2
	test	eax, eax
	je	.L29
	mov	BYTE PTR filePerm[rip+8], 119
	jmp	.L30
.L29:
	mov	BYTE PTR filePerm[rip+8], 45
.L30:
	mov	eax, DWORD PTR st[rip+24]
	and	eax, 1
	test	eax, eax
	je	.L31
	mov	BYTE PTR filePerm[rip+9], 120
	jmp	.L32
.L31:
	mov	BYTE PTR filePerm[rip+9], 45
.L32:
	mov	rax, QWORD PTR pFilePath[rip]
	mov	rsi, rax
	mov	edi, OFFSET FLAT:.LC6
	mov	eax, 0
	call	printf
	mov	rax, QWORD PTR st[rip+16]
	mov	rsi, rax
	mov	edi, OFFSET FLAT:.LC7
	mov	eax, 0
	call	printf
	mov	esi, OFFSET FLAT:filePerm
	mov	edi, OFFSET FLAT:.LC8
	mov	eax, 0
	call	printf
	mov	rax, QWORD PTR st[rip+48]
	mov	rsi, rax
	mov	edi, OFFSET FLAT:.LC9
	mov	eax, 0
	call	printf
	mov	rax, QWORD PTR st[rip+72]
	mov	rdi, rax
	call	printFileAppDateTime
	mov	esi, 0
	mov	edi, OFFSET FLAT:.LC10
	mov	eax, 0
	call	printf
	mov	esi, 8
	mov	edi, OFFSET FLAT:.LC11
	mov	eax, 0
	call	printf
	mov	esi, 24
	mov	edi, OFFSET FLAT:.LC12
	mov	eax, 0
	call	printf
	mov	esi, 16
	mov	edi, OFFSET FLAT:.LC13
	mov	eax, 0
	call	printf
	mov	esi, 28
	mov	edi, OFFSET FLAT:.LC14
	mov	eax, 0
	call	printf
	mov	esi, 32
	mov	edi, OFFSET FLAT:.LC15
	mov	eax, 0
	call	printf
	mov	esi, 40
	mov	edi, OFFSET FLAT:.LC16
	mov	eax, 0
	call	printf
	mov	esi, 48
	mov	edi, OFFSET FLAT:.LC17
	mov	eax, 0
	call	printf
	mov	esi, 56
	mov	edi, OFFSET FLAT:.LC18
	mov	eax, 0
	call	printf
	mov	esi, 64
	mov	edi, OFFSET FLAT:.LC19
	mov	eax, 0
	call	printf
	mov	esi, 72
	mov	edi, OFFSET FLAT:.LC20
	mov	eax, 0
	call	printf
	mov	esi, 88
	mov	edi, OFFSET FLAT:.LC21
	mov	eax, 0
	call	printf
	mov	esi, 104
	mov	edi, OFFSET FLAT:.LC22
	mov	eax, 0
	call	printf
	mov	edi, 10
	call	putchar
	mov	esi, 0
	mov	edi, OFFSET FLAT:.LC23
	mov	eax, 0
	call	printf
	mov	esi, 8
	mov	edi, OFFSET FLAT:.LC24
	mov	eax, 0
	call	printf
	mov	esi, 16
	mov	edi, OFFSET FLAT:.LC25
	mov	eax, 0
	call	printf
	mov	esi, 20
	mov	edi, OFFSET FLAT:.LC26
	mov	eax, 0
	call	printf
	mov	esi, 24
	mov	edi, OFFSET FLAT:.LC27
	mov	eax, 0
	call	printf
	mov	esi, 32
	mov	edi, OFFSET FLAT:.LC28
	mov	eax, 0
	call	printf
	mov	esi, 40
	mov	edi, OFFSET FLAT:.LC29
	mov	eax, 0
	call	printf
	mov	edi, 10
	call	putchar
	mov	esi, 0
	mov	edi, OFFSET FLAT:.LC30
	mov	eax, 0
	call	printf
	mov	esi, 8
	mov	edi, OFFSET FLAT:.LC31
	mov	eax, 0
	call	printf
	mov	esi, 16
	mov	edi, OFFSET FLAT:.LC32
	mov	eax, 0
	call	printf
	mov	esi, 24
	mov	edi, OFFSET FLAT:.LC33
	mov	eax, 0
	call	printf
	mov	eax, DWORD PTR [rbp-4]
.L7:
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
	pop	rbp
	ret
	.size	main, .-main
	.ident	"GCC: (SUSE Linux) 13.2.1 20240206 [revision 67ac78caf31f7cb3202177e6428a46d829b70f23]"
	.section	.note.GNU-stack,"",@progbits
