#############################################################################
#
#	Makefile for userAsm - directory operations
#	John Schwartzman, Forte Systems, Inc.
#	03/31/2024
#
#	Commands:  make [.release], make .debug, make clean
#   Requires:  ../maketest.sh
#
#############################################################################
INCLUDEFILE	:= macro.inc
SHELL 		:= /bin/bash
cc			:= gcc
as			:= yasm
ASM_FLAGS	:= -f elf64
ASM_DFLAGS	:= -f elf64 -g dwarf2
C_FLAGS		:= -Wall -O3 -z noexecstack
C_DFLAGS	:= -Wall -g -O0 -z noexecstack
DEPENDS		:= $(wildcard *.asm)  $(wildcard *.c) $(INCLUDEFILE) Makefile

.release: $(DEPENDS)
	@source ../maketest.sh && test .release .debug
	$(as) $(ASM_FLAGS) fi.asm -o fi.obj
	$(cc) $(C_FLAGS) fi.obj -o fi

.debug: $(DEPENDS)
	@source ../maketest.sh && test .debug .release
	$(as) $(ASM_DFLAGS) fi.asm -o fi.obj
	$(cc) $(C_DFLAGS) fi.obj -o fi

asm_c_prog: fileInfo.c
	gcc -S -fno-asynchronous-unwind-tables -fno-exceptions -masm=intel fi.c -o fi.obj
		#\ -fno-dwarf2-cfi-asm -fno-exceptions -masm=intel fi.c

clean:
	rm -f *.obj .debug .release 
 
#############################################################################
