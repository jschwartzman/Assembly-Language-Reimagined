#############################################################################
#
#	Makefile for myll - directory operations for \ls -lAFh
#	John Schwartzman, Forte Systems, Inc.
#	Tue Dec  3 03:37:25 PM EST 2024mr
#
#	Commands:  make [.release], make .debug, make clean, make asm_c_prog
#   Requires:  ../../maketest.sh
#
#############################################################################
INCLUDEFILE	:= macro.inc
SHELL 		:= /bin/bash
MAKETEST	:= ../../../maketest.sh
cc			:= gcc
as			:= yasm
ASM_FLAGS	:= -f elf64
ASM_DFLAGS	:= -f elf64 -g dwarf2
C_FLAGS		:= -Wall -O3 -z noexecstack
C_DFLAGS	:= -Wall -g -z noexecstack
DEPENDS		:= $(wildcard *.asm) $(INCLUDEFILE) Makefile $(MAKETEST)

.release: $(DEPENDS)
	source $(MAKETEST) && test .release .debug
	$(as) $(ASM_FLAGS) -o myll.obj myll.asm				
	$(as) $(ASM_FLAGS) -o fileInfo.obj fileInfo.asm			
	$(as) $(ASM_FLAGS) -o fileSize.obj fileSize.asm            
	$(as) $(ASM_FLAGS) -o fileTime.obj fileTime.asm            
	$(as) $(ASM_FLAGS) -o listTools.obj listTools.asm			
	$(as) $(ASM_FLAGS) -o quicksortStr.obj quicksortStr.asm	
	$(cc) $(C_FLAGS)   -o myll myll.obj listTools.obj fileInfo.obj fileTime.obj fileSize.obj quicksortStr.obj

.debug: $(DEPENDS)
	source $(MAKETEST) && test .debug .release
	$(as) $(ASM_DFLAGS) -o myll.obj myll.asm				
	$(as) $(ASM_DFLAGS) -o fileInfo.obj fileInfo.asm			
	$(as) $(ASM_DFLAGS) -o fileSize.obj fileSize.asm            
	$(as) $(ASM_DFLAGS) -o fileTime.obj fileTime.asm            
	$(as) $(ASM_DFLAGS) -o listTools.obj listTools.asm			
	$(as) $(ASM_DFLAGS) -o quicksortStr.obj quicksortStr.asm	
	$(cc) $(C_DFLAGS)   -o myll myll.obj listTools.obj fileInfo.obj fileTime.obj fileSize.obj quicksortStr.obj
	
install: .release
	sudo cp myll /usr/local/bin
	sudo cp ../myls/myls /usr/local/bin

clean:
	rm -f *.obj .debug .release
 
#############################################################################
