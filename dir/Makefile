#############################################################################
#
#	Makefile for dir and dir2 - directory operations
#	John Schwartzman, Forte Systems, Inc.
#	Sat Oct 26 03:41:27 AM EDT 2024
#
#	Commands:  make [.release], make .debug, make clean, make asm_c_prog
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
C_DFLAGS	:= -Wall -g -z noexecstack
DEPENDS		:= $(wildcard *.asm) $(INCLUDEFILE) Makefile

.release: $(DEPENDS)
	@source ../maketest.sh && test .release .debug
	$(as) $(ASM_FLAGS) -o dir.obj dir.asm				
	$(as) $(ASM_FLAGS) -o dir2.obj dir2.asm				
	$(as) $(ASM_FLAGS) -o dir3.obj dir3.asm				
	$(as) $(ASM_FLAGS) -o dir4.obj dir4.asm				
	$(cc) $(C_FLAGS)   -o dir   dir.obj
	$(cc) $(C_FLAGS)   -o dir2 dir2.obj
	$(cc) $(C_FLAGS)   -o dir3 dir3.obj
	$(cc) $(C_FLAGS)   -o dir4 dir4.obj

.debug: $(DEPENDS)
	@source ../maketest.sh && test .debug .release
	$(as) $(ASM_DFLAGS) -o dir.obj dir.asm				
	$(as) $(ASM_DFLAGS) -o dir2.obj dir2.asm				
	$(as) $(ASM_DFLAGS) -o dir3.obj dir3.asm				
	$(as) $(ASM_DFLAGS) -o dir4.obj dir4.asm				
	$(cc) $(C_DFLAGS) 	-o dir   dir.obj
	$(cc) $(C_DFLAGS) 	-o dir2 dir2.obj
	$(cc) $(C_DFLAGS) 	-o dir3 dir3.obj
	$(cc) $(C_DFLAGS) 	-o dir4 dir4.obj
	
clean:
	rm -f *.obj .debug .release dir dir1 dir2 dir3 dir4 dir5
 
asm_c_prog: dir.c
	gcc -S -fno-asynchronous-unwind-tables \
		-fno-dwarf2-cfi-asm -fno-exceptions -masm=intel dir.c
#############################################################################
