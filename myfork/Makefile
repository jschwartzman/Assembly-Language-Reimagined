#############################################################################
#
#	Makefile for myfork - directory operations for \ls -lAFh *.*
#	John Schwartzman, Forte Systems, Inc.
#	Sat Sep 28 01:57:47 PM EDT 2024
#
#	Commands:  make [.release], make .debug, make clean, make asm_c_prog
#   Requires:  ../maketest.sh
#
#############################################################################
INCLUDEFILE	:= macro.inc
SHELL 		:= /bin/bash
MAKETEST	:= ../maketest.sh
cc			:= gcc
as			:= yasm
ASM_FLAGS	:= -f elf64
ASM_DFLAGS	:= -f elf64 -g dwarf2
C_FLAGS		:= -Wall -O3 -z noexecstack
C_DFLAGS	:= -Wall -g -z noexecstack
DEPENDS		:= $(wildcard *.asm) $(INCLUDEFILE) $(MAKETEST) Makefile

.release: $(DEPENDS)
	source $(MAKETEST) && test .release .debug
	$(as) $(ASM_FLAGS) -o myfork.obj myfork.asm				
	$(as) $(ASM_FLAGS) -o fileInfo.obj fileInfo.asm			
	$(as) $(ASM_FLAGS) -o fileSize.obj fileSize.asm            
	$(as) $(ASM_FLAGS) -o fileTime.obj fileTime.asm            
	$(as) $(ASM_FLAGS) -o listTools.obj listTools.asm			
	$(cc) $(C_FLAGS)   -o myfork myfork.obj listTools.obj fileInfo.obj fileTime.obj fileSize.obj

.debug: $(DEPENDS)
	@source $(MAKETEST) && test .debug .release
	$(as) $(ASM_DFLAGS) -o myfork.obj myfork.asm				
	$(as) $(ASM_DFLAGS) -o fileInfo.obj fileInfo.asm			
	$(as) $(ASM_DFLAGS) -o fileSize.obj fileSize.asm            
	$(as) $(ASM_DFLAGS) -o fileTime.obj fileTime.asm            
	$(as) $(ASM_DFLAGS) -o listTools.obj listTools.asm			
	$(cc) $(C_DFLAGS)   -o myfork myfork.obj listTools.obj fileInfo.obj fileTime.obj fileSize.obj

install: .release
	sudo cp myfork /usr/local/bin
	# sudo cp ../myll/myll /usr/local/bin

clean:
	rm -f *.obj .debug .release
 
#############################################################################
