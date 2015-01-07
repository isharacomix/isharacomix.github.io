;-------------------------------------------------------------------------------
;	MOVING.ASM
;  Barry Peddycord III
;  @isharacomix
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;	Includes
;-------------------------------------------------------------------------------
INCLUDE "hardware.inc"
INCLUDE "header.asm"

;-------------------------------------------------------------------------------
; Variables (starting in GB RAM)
;-------------------------------------------------------------------------------
DUDE_X		EQU		$C000
DUDE_Y		EQU		$C001
TIMEOUT  	EQU		$C002

;-------------------------------------------------------------------------------
; User Program
;-------------------------------------------------------------------------------
SECTION "Program Start",HOME[$0150]
Start:
	di					; Disable interrupts
	ld	sp,$FFFE		; Assign the stack to the GB scratch area
	call WAIT_VBLANK	; Wait for vblank

	ld	a,0				;
	ldh	[rLCDC],a		; turn off the LCD

	ld	a,1				; Initial variable values
	ld  [DUDE_X],a		;
	ld  [DUDE_Y],a		;
	ld  [TIMEOUT],a		;

	call CLEAR_MAP		; clear the BG map
	call LOAD_TILES		; load up our tiles
	call LOAD_MAP		; load up our map

	ld	a,%11100100		; load a normal palette up 11 10 01 00 - dark->light
	ldh	[rBGP],a		; load the BackGround Palette (BGP)

	ld	a,%10010001		;
	ldh	[rLCDC],a		; turn on LCD, pick the pixel data src, turn on BG



; Endless loop wherein we handle user input. We start by waiting for the
; vertical blank to occur. Whenever we press a button, we avoid the keypress
; routine for a number of ticks.
Loop:

	call WAIT_VBLANK

	; TIMEOUT contains the number of ticks left before we do another keypress.
	; if it's 0, we move on, if it's >0, we subtract one and wait for another
	; vblank.
	ld a,[TIMEOUT]
	cp $00
	jr nz,TICK
	jr TOCK
TICK:
    dec a
	ld [TIMEOUT],a
	jr Loop


	; Otherwise, we start getting input!
TOCK:
	call GET_INPUT ; B = D.U.L.R.ST.SE.B.A

	ld c,0

	; We check keys by shifting left. The carry is true if the button was
	; pressed and false otherwise. Down and Up are dummied out right now. :P
down:
	sla B
	jp NC,up
	ld A,[DUDE_Y]
	dec A
	ld [DUDE_Y],A
	ld c,1
up:
	sla B
	jp NC,left
	ld A,[DUDE_Y]
	inc a
	ld [DUDE_Y],A
	ld c,1
left:
	sla B
	jp NC, right
	ld A,[DUDE_X]
	dec A
	ld [DUDE_X],A
	ld c,1
right:
	sla B
	jp NC,lend
	ld A,[DUDE_X]
	inc A
	ld [DUDE_X],A
	ld c,1
lend:
	ld a,c
	cp $0
	jp Z,Loop
	call CLEAR_MAP		; clear the BG map
	call LOAD_MAP		; load up our map
	ld a,10				; set a short delay
	ld [TIMEOUT],a
	jp Loop




;***************************************************************
;* Subroutines
;***************************************************************
	SECTION "Support Routines",HOME

; This subroutine destroys A and sets B to the buttons
;
; Gameboy input is kind of weird. There is a four bit data bus (P10-P13) that
; connects to the lower four bits of $FF00. Each bus is connected to two buttons
; so you can control the P14/P15 line to filter one of them out by setting the
; line to 0 (normally both lines are 1).
GET_INPUT:
    LD A,$20     ; 0 on Bit 4 (Port 14) focuses input on D/U/L/R
    LD [$FF00],A ; Write to the controller controller
    LD A,[$FF00] ;
    LD A,[$FF00] ; Read multiple times to introduce a delay
    CPL          ; Flip! Bits 0-3 are now 1s if corresponding buttons pressed
    AND $0F      ; Mask the upper bits
    SWAP A       ;
    LD B,A       ; Store first part of result in B: D.U.L.R.x.x.x.x
    LD A,$10     ; 0 on Bit 5 focuses input on ST.SE.B.A
    LD [$FF00],A ; Write to the controller controller again
    LD A,[$FF00] ;
    LD A,[$FF00] ;
    LD A,[$FF00] ;
    LD A,[$FF00] ;
    LD A,[$FF00] ;
    LD A,[$FF00] ; Read multiple times to introduce a delay
    CPL          ;
    AND $0F      ; Mask the upper bits.
    OR B         ;
    LD B,A       ; At this point: B = D.U.L.R.ST.SE.B.A
    LD A,[$FF8B] ; Read old button status from RAM
    LD A,$30     ; Set both the P14 and P15 lines to 1
    LD [$FF00],A ;
	RET			 ;



WAIT_VBLANK:
    ld      a,[$FF0F]		;
    and     a,$1            ; V-Blank interrupt ?
    jr      z,WAIT_VBLANK          ; No, some other interrupt

    xor     a
    ld      [$FF0F],a   ; Clear V-Blank flag
	ret				;done

CLEAR_MAP:
	ld	hl,_SCRN0		;loads the address of the bg map ($9800) into HL
	ld	bc,32*32		;since we have 32x32 tiles, we'll need a counter so we can clear all of them
	ld	a,0			;load 0 into A (since our tile 0 is blank)
CLEAR_MAP_LOOP:
	ld  a,0
	ld	[hl+],a		;load A into HL, then increment HL (the HL+)
	dec	bc			;decrement our counter
	ld	a,b			;load B into A
	or	c			;if B or C != 0
	jr	nz,CLEAR_MAP_LOOP	;then loop
	ret				;done


LOAD_TILES:
	ld	hl,HELLO_TILES
	ld	de,_VRAM
	ld	bc,9*16	;we have 9 tiles and each tile takes 16 bytes
LOAD_TILES_LOOP:
	ld	a,[hl+]	;get a byte from our tiles, and increment.
	ld	[de],a	;put that byte in VRAM and
	inc	de		;increment.
	dec	bc		;bc=bc-1.
	ld	a,b		;if b or c != 0,
	or	c		;
	jr	nz,LOAD_TILES_LOOP	;then loop.
	ret			;done


; Goal: HL should be the memory location of the map
;       DE should be the where the map goes
;		I want to add DUDE_X to DE
LOAD_MAP:
	ld	hl,HELLO_MAP	;our little map
	ld	de,_SCRN0	;where our map goes

	ld  a,[DUDE_X]
FIRST_LOOP:
    inc de
	dec a
	jr nz, FIRST_LOOP
	ld	c,12		;since we are only loading 12 tiles
LOAD_MAP_LOOP:
	ld	a,[hl+]	;get a byte of the map and inc hl
	ld	[de],a	;put the byte at de
	inc	de		;duh...
	dec	c		;decrement our counter
	jr	nz,LOAD_MAP_LOOP	;and of the counter != 0 then loop
	ret			;done

;********************************************************************
; This section was generated by GBTD v2.2

 SECTION "Tiles", HOME

; Start of tile array.
HELLO_TILES::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $C6,$C6,$C6,$C6,$C6,$C6,$FE,$FE
DB $FE,$FE,$C6,$C6,$C6,$C6,$C6,$C6
DB $FE,$FE,$FE,$FE,$80,$80,$F8,$F8
DB $F8,$F8,$80,$80,$FE,$FE,$FE,$FE
DB $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
DB $C0,$C0,$C0,$C0,$FE,$FE,$FE,$FE
DB $7C,$7C,$FE,$FE,$C6,$C6,$C6,$C6
DB $C6,$C6,$C6,$C6,$FE,$FE,$7C,$7C
DB $C6,$C6,$C6,$C6,$C6,$C6,$C6,$C6
DB $D6,$D6,$D6,$D6,$FE,$FE,$6C,$6C
DB $FC,$FC,$FE,$FE,$C6,$C6,$FC,$FC
DB $FC,$FC,$C6,$C6,$C6,$C6,$C6,$C6
DB $FC,$FC,$FE,$FE,$C6,$C6,$C6,$C6
DB $C6,$C6,$C6,$C6,$FE,$FE,$FC,$FC
DB $6C,$6C,$6C,$6C,$6C,$6C,$6C,$6C
DB $6C,$6C,$6C,$6C,$00,$00,$6C,$6C

;************************************************************
;* tile map

SECTION "Map",HOME

HELLO_MAP::
DB $01,$02,$03,$03,$04,$00,$05,$04,$06,$03,$07,$08


SECTION "ROM1",ROMX
POTATO::
DB $00

;*** End Of File ***
