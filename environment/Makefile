#############################################################################
#
#	Makefile for environment
# 	John Schwartzman, Forte Systems, Inc.
#   05/31/2023
#
#	Commands:  make [.release], make .debug, make clean, make install
#   Requires:  ../maketest.sh
#
#############################################################################
PROG  		:= environment
PROG2 		:= env
PROG3		:= random
SHELL 		:= /bin/bash
ASM_FLAGS 	:= -f elf64
ASM_DFLAGS 	:= -f elf64 -g dwarf2
C_FLAGS		:= -Wall -O3 -z noexecstack
C_DFLAGS	:= -Wall -g -z noexecstack
as			:= yasm
cc			:= gcc

.release: $(PROG).asm $(PROG).c random.c Makefile
	@source ../maketest.sh && test .release .debug
	$(as) $(ASM_FLAGS) -o $(PROG).obj -l $(PROG).lst $(PROG).asm
	$(as) $(ASM_FLAGS) -o $(PROG2).obj $(PROG2).asm
	$(as) $(ASM_FLAGS) -o $(PROG3).obj $(PROG3).asm
	$(cc) $(C_FLAGS) $(PROG).c $(PROG).obj -o $(PROG)
	$(cc) $(C_FLAGS) $(PROG).c $(PROG2).obj -o $(PROG2)
	$(cc) $(C_FLAGS) $(PROG3).c $(PROG3).obj -o $(PROG3)

.debug: $(PROG).asm $(PROG).c random.c Makefile
	@source ../maketest.sh && test .debug .release
	$(as) $(ASM_DFLAGS) -o $(PROG).obj -l $(PROG).lst $(PROG).asm
	$(as) $(ASM_DFLAGS) -o $(PROG2).obj $(PROG2).asm
	$(as) $(ASM_DFLAGS) -o $(PROG3).obj $(PROG3).asm
	$(cc) $(C_DFLAGS) $(PROG).c $(PROG).obj -o $(PROG)
	$(cc) $(C_DFLAGS) $(PROG).c $(PROG2).obj -o $(PROG2)
	$(cc) $(C_DFLAGS) $(PROG3).c $(PROG3).obj -o $(PROG3)

install: .release
	sudo cp env /usr/local/bin/jsenv

clean:
	rm -f $(PROG) $(PROG).obj $(PROG).lst a.out .debug .release
#############################################################################
