#############################################################################
#
#	Makefile for factorial
# 	05/28/2023
#
#	Commands:  make [DEF=__COMMA__] [.release]
#			   make [DEF=__COMMA__] .debug
#			   make clean
#   Requires:  ../maketest.sh
#
#############################################################################
PROG  := factorial
SHELL := /bin/bash
EXT	  := ../commaSeparate/commaSeparate

ifeq ($(DEF), __COMMA__)	######### use commaSeparate for output ##########

.release: $(PROG).asm $(EXT).asm $(PROG).c Makefile
	$(info ##### release __COMMA__ build #####)
	@source ../maketest.sh && test .release .debug
	yasm -f elf64 $(EXT).asm -o commaSeparate.obj 
	yasm -D $(DEF) -f elf64 $(PROG).asm -o $(PROG).obj
	gcc -z noexecstack $(PROG).obj commaSeparate.obj -o $(PROG)
	gcc -Wall -O3 -z noexecstack -D $(DEF) $(PROG).c commaSeparate.obj
 
.debug: $(PROG).asm Makefile $(EXT).asm $(PROG).c Makefile
	$(info ##### debug __COMMA__ build #####)
	@source ../maketest.sh && test .debug .release
	yasm -f elf64 -g dwarf2 -o commaSeparate.obj $(EXT).asm
	yasm -D $(DEF) -f elf64 -g dwarf2 -o $(PROG).obj $(PROG).asm
	gcc -g -z noexecstack $(PROG).obj commaSeparate.obj -o $(PROG)
	gcc -g -z noexecstack -D $(DEF) $(PROG).c commaSeparate.obj

else						############### output normally #################

.release: $(PROG).asm Makefile $(PROG).c
	@source ../maketest.sh && test .release .debug
	yasm -f elf64 -o $(PROG).obj -l $(PROG).lst $(PROG).asm
	gcc -z noexecstack $(PROG).obj -o $(PROG)
	gcc -Wall -O3 $(PROG).c

.debug: $(PROG).asm Makefile $(PROG).c
	@source ../maketest.sh && test .debug .release
	yasm -f elf64 -g dwarf2 -o $(PROG).obj -l $(PROG).lst $(PROG).asm
	gcc -g -z noexecstack $(PROG).obj -o $(PROG)
	gcc -g $(PROG).c

endif	######################## use commaSeparate ##########################

clean:
	rm -f $(PROG) *.obj a.out *.lst .debug .release
#############################################################################
