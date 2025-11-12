#############################################################################
#
#	Makefile for dir - directory operations
#	John Schwartzman, Forte Systems, Inc.
#	03/18/2024
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
# DEPENDS		:= $(wildcard *.asm) $(INCLUDEFILE) Makefile lstat.c

.release: directory.c fileSize.c listTools.asm dir2.asm dir3.asm fileType.asm $(INCLUDEFILE)
	@source ../maketest.sh && test .release .debug
	$(as) $(ASM_FLAGS) dir3.asm -o dir3.obj
	$(as) $(ASM_FLAGS) listTools.asm -o listTools.obj
	$(as) $(ASM_FLAGS) fileType.asm -o fileType.obj
	$(cc) $(C_FLAGS) -c directory.c -o directory.obj 
	$(cc) $(C_FLAGS) -c fileSize.c -o fileSize.obj
	$(cc) $(C_FLAGS) -o directory directory.obj fileSize.obj
	$(cc) $(C_FLAGS) -o dir2 dir2.obj
	$(cc) $(C_FLAGS) -o dir3 dir3.obj listTools.obj fileType.obj

.debug: directory.c fileSize.c fileType.c listTools.asm dir2.asm dir3.asm fileType.asm $(INCLUDEFILE) Makefile
	@source ../maketest.sh && test .debug .release
	# $(as) $(ASM_DFLAGS) dir2.asm -o dir2.obj
	$(as) $(ASM_DFLAGS) dir3.asm -o dir3.obj
	# $(as) $(ASM_DFLAGS) listTools.asm -o listTools.obj
	# $(as) $(ASM_DFLAGS) fileType.asm -o fileType.obj
	# $(cc) $(C_DFLAGS) -c fileInfo.c -o fileInfo.obj
	# $(cc) $(C_DFLAGS) -c directory.c -o directory.obj
	# $(cc) $(C_DFLAGS) -c fileSize.c -o fileSize.obj
	$(cc) $(C_DFLAGS) -c fileInfo.c -o fileInfo.obj
	# $(cc) $(C_DFLAGS) -o directory directory.obj fileSize.obj fileType.obj
	# $(cc) $(C_DFLAGS) -o dir2 dir2.obj
	# $(cc) $(C_DFLAGS) -o dir3 dir3.obj fileType.obj fileSize.obj
	$(cc) $(C_DFLAGS) -o main fileInfo.obj

asm_c_prog: fileType.c
	gcc -S -fno-asynchronous-unwind-tables \
		-fno-dwarf2-cfi-asm -fno-exceptions -masm=intel fileInfo.c

clean:
	rm -f *.obj .debug .release 
 
#############################################################################
