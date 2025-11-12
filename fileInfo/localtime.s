	.file	"localtime.c"
	.intel_syntax noprefix
	.text
	.globl	timePtr
	.bss
	.align 8
	.type	timePtr, @object
	.size	timePtr, 8
timePtr:
	.zero	8
	.globl	timeFmt
	.section	.rodata
.LC0:
	.string	"%s\n"
	.data
	.align 8
	.type	timeFmt, @object
	.size	timeFmt, 8
timeFmt:
	.quad	.LC0
	.globl	buf
	.bss
	.align 32
	.type	buf, @object
	.size	buf, 256
buf:
	.zero	256
	.globl	theTime
	.align 8
	.type	theTime, @object
	.size	theTime, 8
theTime:
	.zero	8
	.section	.rodata
.LC1:
	.string	"%b %d %H:%M"
	.text
	.globl	main
	.type	main, @function
main:
	push	rbp
	mov	rbp, rsp
	mov	edi, OFFSET FLAT:theTime
	call	time
	mov	edi, OFFSET FLAT:theTime
	call	localtime
	mov	QWORD PTR timePtr[rip], rax
	mov	rax, QWORD PTR timePtr[rip]
	mov	rcx, rax
	mov	edx, OFFSET FLAT:.LC1
	mov	esi, 256
	mov	edi, OFFSET FLAT:buf
	call	strftime
	mov	rax, QWORD PTR timeFmt[rip]
	mov	esi, OFFSET FLAT:buf
	mov	rdi, rax
	mov	eax, 0
	call	printf
	mov	eax, 0
	pop	rbp
	ret
	.size	main, .-main
	.ident	"GCC: (SUSE Linux) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
