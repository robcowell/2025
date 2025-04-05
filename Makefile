.PRECIOUS: %.prg %.d64
TASS64=D:/Dropbox/C64\ Stuff/Windows/64tass-1.53.1515/64tass
KICK=d:/Downloads/KickAssembler/KickAss.jar
ACME=D:/acme0.97win/acme/acme
EXOMIZER=D:/Dropbox/C64\ Stuff/Windows/exo/win32/exomizer
CC1541=D:/Dropbox/C64\ Stuff/Windows/cc1541
EXOMIZERFLAGS=sfx basic -n
VICE=D:/WinVICE-3.1-x64/x64sc
VICEFLAGS=-keybuf "\88"
SOURCES=$(wildcard *.asm)
OBJECTS=$(SOURCES:.asm=.prg)

%.prg: %.asm
	java -jar $(KICK) $<
#	$(TASS64) -a $< -o $@
#	$(ACME) --cpu 6510 --format cbm --outfile $@ $<

%.prg.exo: %.prg
	$(EXOMIZER) $(EXOMIZERFLAGS) $< -o $@

%: %.d64
	-$(VICE) $(VICEFLAGS) $<

%.d64: %.prg.exo
	$(CC1541) -n $@ -f $< -w $< $@