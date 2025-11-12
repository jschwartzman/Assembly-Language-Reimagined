#############################################################################
#
#	Makefile for userAsm - directory operations
#	John Schwartzman, Forte Systems, Inc.
#	06/16/2024
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
	$(as) $(ASM_FLAGS) fileSize.asm -o fileSize.obj -l fileSize.lst
	$(as) $(ASM_FLAGS) fileTime.asm -o fileTime.obj -l fileTime.lst
	$(as) $(ASM_FLAGS) fileInfo.asm -o fileInfo.obj -l fileInfo.lst
	$(as) $(ASM_FLAGS) -D __MAIN__ fi.asm -o fi.obj 
	$(cc) $(C_FLAGS) fi.obj fileSize.obj fileTime.obj -o fi
	$(cc) $(C_FLAGS) fileInfo.obj fileSize.obj fileTime.obj -o fileInfo

.debug: $(DEPENDS)
	@source ../maketest.sh && test .debug .release
	$(as) $(ASM_DFLAGS) fileSize.asm -o fileSize.obj -l fileSize.lst
	$(as) $(ASM_DFLAGS) fileTime.asm -o fileTime.obj -l fileTime.lst
	$(as) $(ASM_DFLAGS) fileInfo.asm -o fileInfo.obj -l fileInfo.lst
	$(as) $(ASM_DFLAGS) -D __MAIN__ fi.asm -o fi.obj 
	# $(as) $(ASM_DFLAGS) -D __MAIN__ dir.asm -o dir.obj 
	$(cc) $(C_DFLAGS) fi.obj fileSize.obj fileTime.obj -o fi
	$(cc) $(C_DFLAGS) fileInfo.obj fileSize.obj fileTime.obj -o fileInfo

asm_c_prog: fileInfo.c
	gcc -S -fno-asynchronous-unwind-tables -fno-exceptions -masm=intel \
		-fno-dwarf2-cfi-asm -fno-exceptions -masm=intel .c

clean:
	rm -f *.obj .debug .release 
 
#############################################################################
