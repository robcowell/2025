*=$0801 "Basic Program"
	BasicUpstart($0810)

	/*
    *=$1000		//music at $1000	to $5E23 - rules out VIC banks 0 and 1
	.import binary "coldprocess.sid",$7c+2
    */

    .var music = LoadSid("coldprocess.sid")

	//Advanced art studio file specs:
	//Load address: $a000 - $c71F

	// Load address needs to be in same address range as the VIC bank
	// that you're going to copy it to, according to Vanja

	//$a000 - $bF3F Bitmap data
	//$bF40 - $c327 Screen RAM (copy to VIC Bank start address + $0400)
	//$c328 Border colour
	//$c329 Background colour
	//$c338 - $c71F Colour RAM (copy to $d800->)

	*=$a000
	.import binary "logo.ocp",2

	*=$0810		//code at $0810

	sei		//disable interrupts

	// here we shift BASIC and Kernal ROM routines out the way
	// so we can use the RAM space at the addresses they used.
	lda #$35
	sta $01

	lda #music.startSong-1
    jsr music.init

	//-------------------------
	//-- DISPLAY PIC ATTEMPT --
	//-------------------------

	// black background/border
	lda #$00
	sta $d020
	sta $d021

	ldx #$00    // zero X register

setpic:
//	start copying screen data - screen ram
	lda $bF40,x
	sta $8400,x

	lda $c040,x
	sta $8500,x

	lda $c140,x
	sta $8600,x

	lda $c240,x
	sta $8700,x

//	 start copying color ram

	lda $c338,x
	sta $d800,x

	lda $c438,x
	sta $d900,x

	lda $c538,x
	sta $da00,x

	lda $c638,x
	sta $db00,x

	inx
	bne setpic

//	 Go into bitmap mode
	lda #$3b
	sta $d011

//	 Go into multicolor mode
	lda #$18
	sta $d016

	// Select VIC bank (last two digits of the ora statement)
	// 00 = bank 3 - $C000 - $FFFF
	// 01 = bank 2 - $8000 - $BFFF
	// 10 = bank 1 - $4000 - $7FFF
	// 11 = bank 0 - $0000 - $3FFF

 	lda $DD00
	and #%11111100
	ora #%00000001
	sta $dd00

	// Set VIC screen and font pointers

	lda #$18
 	sta $d018

    //set up irq
    sei

    // here we shift BASIC and Kernal ROM routines out the way
	// so we can use the RAM space at the addresses they used.
	lda #$35
	sta $01


	lda #<irq
	sta $0314
	lda #>irq
	sta $0315
	
	asl $d019

	lda #$7b
	sta $dc0d

	lda #$81
	sta $d01a

	lda #$3b
	sta $d011

	lda #$18
	sta $d016

	lda #$3A
	sta $d012

	cli
	jmp *


irq:
	
	//preserve registers
	pha		// store register a in stack
	txa
	pha		// store register x in stack
	tya
	pha		//store register y in stack

	inc $d020	//bg color
	jsr music.play	//music play 
	dec $d020	//bg color
	
	pla
	tay		//restore register y
	pla
	tax		//restore register x
	pla		//restore register a

    lda #$ff
	sta $d019	//acknowledge interrupt
	jmp $ea31	//original irq pointer, just in case
	rti

/*
loop:
	lda #$3A	//wait for the raster beam to reach line #$3a
	cmp $d012
	bne *-3

	jsr $1003	//play the music

	jmp loop	//jump to loop
*/

*=music.location "Music"
.fill music.size, music.getData(i)