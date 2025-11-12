#############################################################################
#
#	Makefile for arrayDir
#	John Schwartzman, Forte Systems, Inc.
#	11/29/2023
#
#	Commands:  make .debug DEF=__bubblesort__
#   Requires:  ./maketest.sh
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
# DEF			:= __quicksort__		# or __bubblesort__
.PHONY: clean

ifeq	($(DEF), __bubblesort__)	#########################################

.release: $(DEPENDS)
	@source ../maketest.sh && test .release .debug
	$(as) $(ASM_FLAGS) -o bubblesortStr.obj bubblesortStr.asm
	$(as) $(ASM_FLAGS) -o arrayTools.obj arrayTools.asm
	$(as) $(ASM_FLAGS) -D $(DEF) -o arrayDir.obj arrayDir.asm
	$(cc) $(C_FLAGS) arrayDir.obj bubblesortStr.obj arrayTools.obj -o arrayDir

.debug: $(DEPENDS)
	@source ../maketest.sh && test .debug .release
	$(as) $(ASM_DFLAGS) -o bubblesortStr.obj bubblesortStr.asm
	$(as) $(ASM_DFLAGS) -o arrayTools.obj arrayTools.asm
	$(as) $(ASM_DFLAGS) -D $(DEF) -o arrayDir.obj arrayDir.asm
	$(cc) $(C_DFLAGS) arrayDir.obj bubblesortStr.obj arrayTools.obj -o arrayDir

endif
ifeq	($(DEF), __quicksort__)	#########################################

.release: $(DEPENDS)
	@source ../maketest.sh && test .release .debug
	$(as) $(ASM_FLAGS) -o qsortPartStr.obj qsortPartStr.asm
	$(as) $(ASM_FLAGS) -o arrayToolsStr.obj arrayToolsStr.asm
	$(as) $(ASM_FLAGS) -D $(DEF) -o arrayDir.obj arrayDir.asm
	$(cc) $(C_FLAGS) arrayDir.obj qsortPartStr.obj arrayTools.obj -o arrayDir

.debug: $(DEPENDS)
	@source ../maketest.sh && test .debug .release
	$(as) $(ASM_DFLAGS) -o qsortPartStr.obj qsortPartStr.asm
	$(as) $(ASM_DFLAGS) -o arrayTools.obj arrayTools.asm
	$(as) $(ASM_DFLAGS) -D $(DEF) -o arrayDir.obj arrayDir.asm
	$(cc) $(C_DFLAGS) arrayDir.obj qsortPartStr.obj arrayTools.obj -o arrayDir

endif

clean:
	rm -f *.obj .debug .release arrayDir
 
#############################################################################
