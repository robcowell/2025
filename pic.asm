*=$0801
    .byte $0C,$08,$0A,$00,$9E,$20,$32,$30,$36,$34,$00,$00,$00,$00,$00
    // BASIC stub: SYS 2064

*=$1000
.import binary "coldprocess.sid",$7c+2

*=$a000
.import binary "logo.ocp",2

*=$0810

    sei
    lda #<irq
    sta $0314
    lda #>irq
    sta $0315
    lda #$01
    sta $d01a
    lda #$20
    sta $d012
    lda #$ff
    sta $d019
    lda #$7f
    sta $dc0d
    cli

    // --- SID init ---
    lda #$00
    ldx #$00
    ldy #$00
    jsr $1000      // SID init

    // --- Image setup below ---
    lda #$00
    sta $d020
    sta $d021

    ldx #$00
setpic:
    lda $bF40,x
    sta $8400,x
    lda $c040,x
    sta $8500,x
    lda $c140,x
    sta $8600,x
    lda $c240,x
    sta $8700,x
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

    lda #$3b
    sta $d011
    lda #$18
    sta $d016
    lda $dd00
    and #%11111100
    ora #%00000001
    sta $dd00
    lda #$18
    sta $d018

mainloop:
    jmp mainloop

irq:
    lda #$ff
    sta $d019
    inc $d020
    jsr $1003      // Play SID music
    dec $d020
    jmp $ea31

