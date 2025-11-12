#############################################################################
#
#	Makefile for uname2
# 	John Schwartzman, Forte Systems, Inc.
# 	09/19/2024
#
#	Commands:  make [.release], make .debug, make clean, make install
#   Requires:  ../maketest.sh
#
#############################################################################
PROG  		:= uname2
PROG2		:= readFile
SHELL 		:= /bin/bash
ASM_FLAGS	:= -f elf64
ASM_DFLAGS	:= -f elf64 -g dwarf2
C_FLAGS		:= -Wall -O3 -z noexecstack
C_DFLAGS	:= -Wall -g -z noexecstack

.release: $(PROG).asm $(PROG2).asm Makefile
	$(info ##### release mode #####)
	@source ../maketest.sh && test .release .debug
	yasm $(ASM_FLAGS) -o $(PROG).obj $(PROG).asm	# assemble
	yasm $(ASM_FLAGS) -o $(PROG2).obj $(PROG2).asm	# assemble
	gcc $(C_FLAGS) $(PROG).obj -o $(PROG)			# link
	gcc $(C_FLAGS) $(PROG2).obj -o $(PROG2)			# link

.debug: $(PROG).asm $(PROG2).asm Makefile
	$(info ##### debug mode #####)
	@source ../maketest.sh && test .debug .release
	yasm $(ASM_DFLAGS) -o $(PROG).obj $(PROG).asm	# assemble
	yasm $(ASM_DFLAGS) -o $(PROG2).obj $(PROG2).asm	# assemble
	gcc $(C_DFLAGS) $(PROG).obj -o $(PROG)			# link
	gcc $(C_DFLAGS) $(PROG2).obj -o $(PROG2)		# link

install: .release
	sudo cp uname2 /usr/local/bin/
	sudo cp os-distro.sh /usr/local/bin/os-distro

clean:
	rm -f $(PROG) $(PROG2) *.obj .debug .release
#############################################################################
