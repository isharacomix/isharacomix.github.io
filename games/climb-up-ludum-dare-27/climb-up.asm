;----------------------------------------
; ### #   ### # # ###    # # ### # #
; #   #    #  ### # #    # # # # # #
; #   #    #  ### ##     # # ### # #
; #   #    #  ### # #    # # #      
; ### ### ### # # ###    ### #   # #
;
; CLIMB UP!! - Ludum Dare 27 Compo by
; Barry "IsharaComix" Peddycord III
;
; Theme: 10 Seconds
; Other theme: Death is useful
;
; In the game of CLIMB UP!!, you want to jump out of the top of the stage.
; But you don't want to get your hands dirty, so you send your lil'dudes to
; get there for you. Lil'dudes can push blocks around and jump pretty high,
; but have tremendously short lifespans. After 10 seconds, they die. But
; luckily, dead lil'dudes are particularly useful as stepping stones, as they
; can be pushed around and jumped on like blocks.
;
; How many lil'dudes do you have to go through to reach the top?
;
; Controls:
;   Left and Right, move left and right - push blocks in way
;   A, jump
;
;----------------------------------------
START:                                  ;
    .define PLAYER_X=$210
    .define PLAYER_Y=$220
    .define PLAYER_S=$230
    .define PLAYER_P=$240
    .define PLAYER_V=$250
    .define CURRENT_X=$201
    .define CURRENT_Y=$202
    .define CURRENT_V=$203
    .define BLOCK_POINT=$204
    .define TIMER_HI=$205
    .define TIMER_LO=$206
    .define ANIM_TICK=$207

    ; Load the first stage into the game.
    ; This initializes everything
    LDA #>stage1
    STA stage_pointer
    LDA #<stage1
    STA stage_pointer+1
    JSR load_stage
    LDA #10
    STA ANIM_TICK
                                        ;
    LDA #%10010000                      ; Turn back on rendering
    STA PPUCTRL                         ;                             ;
    LDA #%00011110
    STA PPUMASK
INFLOOP: JMP INFLOOP                    ;
;----------------------------------------
;
; The NMI (non-maskable interrupt) code is run whenever
; the screen refreshes.
;----------------------------------------
NMI:                                    ;
    LDA #%00010000                      ; Turn off interrupts
    STA PPUCTRL                         ;
    
    ; If we win, load the next stage.
    LDA PLAYER_Y
    CMP #10
    BCS nowin
    JSR load_stage
nowin:
    
    JSR control                         ;
    LDA #$10
    STA $E2
ogravloop:
    LDX $E2
    DEX
    STX ignore_me
    LDA PLAYER_X,X
    BEQ noexist
    STA CURRENT_X
    LDA PLAYER_Y,X
    STA CURRENT_Y
    LDA PLAYER_V,X
    STA CURRENT_V
    JSR gravity                         ;
    LDX $E2
    DEX
    LDA CURRENT_X
    STA PLAYER_X,X
    LDA CURRENT_Y
    STA PLAYER_Y,X
    LDA CURRENT_V
    STA PLAYER_V,X
  noexist:
    DEC $E2
    BNE ogravloop
    JSR render                          ;
    
    ;LDA TIMER_LO
    ;LDX #16
    ;CMP #30
    ;BCS drawtimertime
    ;LDX #17
;drawtimertime:
    ;STX PLAYER_S
    
    ; Count down the timer. After apx 10 sec, the player dies
    DEC TIMER_LO
    BNE timeout
    LDA #60
    STA TIMER_LO
    DEC TIMER_HI
    BNE timeout
    LDA #10
    STA TIMER_HI
    JSR dienow
timeout:
    LDA #%10010000                      ; Turn back on rendering
    STA PPUCTRL                         ;
    RTI                                 ; Return from interrupt whenever
;---------------------------------------- the frame code is finished.





;----------------------------------------
; CONTROL
;
; This subroutine handles the controller.
;----------------------------------------
control:                                ; We do the fancy reader
    LDA #0
    STA ignore_me
    LDX #9                              ; Start with 9
    STX CONTROL1                        ; Strobe
    DEX                                 ; Now it's 8
    STX CONTROL1                        ;
conloop:                                ;
    LDA CONTROL1                        ; Read button into bit 1
    ROR A                               ; Shift into carry
    ROL $FF                             ; Shift back into $FF
    DEX                                 ; 8 times
    BNE conloop                         ;
    LDA $FF                             ; A register contains all buttons.
    
    
    ; jump
    LDA $FF
    AND #%10000000
    BEQ nojumping
    LDA PLAYER_V
    BNE nojumping
    LDA #-8
    STA PLAYER_V
    LDA #%01001100
    STA SQ1VOL
    LDA #%10000000
    STA SQ1LO
    LDA #%10001001
    STA SQ1HI
    LDA #%11001001
    STA SQ1SWEEP
    LDA #11
    STA SNDCHAN
nojumping:
    LDA $FF
    LDX #0                              ;
    AND #%00000011                      ; Check to see if left/right was pressed
    BEQ notmoving                       ;
    CMP #%00000010                      ;
    BCC right                           ;
    BNE notmoving                       ;
    DEX                                 ;
    DEX                                 ;
    JSR lrmove                          ;
    RTS                                 ;
right:                                  ;
    INX                                 ;
    INX                                 ;
    JSR lrmove                          ;
notmoving:                              ;   
    RTS                                 ;
;----------------------------------------



;----------------------------------------
; LRMOVE
;
; Attempt to move left or right by the
; value in X. Does not check error
; conditions. Movement will not occur if
; there is a background obstacle
;----------------------------------------
lrmove:                                 ;
    DEC ANIM_TICK
    BNE noanim
    LDA PLAYER_S
    EOR #1
    STA PLAYER_S
    LDY #10
    STY ANIM_TICK
  noanim:
    CLC
    STX $E3
    TXA
    ADC PLAYER_X
    TAX
    LDY PLAYER_Y
    DEY
    STA $F8
    JSR collision
    CMP #0
    BNE movecollided
        
    LDA $F8
    STA PLAYER_X
    RTS
movecollided:
    LDA collide_me
    BEQ nomovepush
    SEC
    SBC #1
    STA ignore_me  ; $E4 contains what we collided with
    TAX
    LDY PLAYER_Y,X
    LDA PLAYER_X,X
    CLC
    ADC $E3
    TAX
    JSR collision
    CMP #0
    BNE nomovepush
    LDA $F8
    STA PLAYER_X
    LDX ignore_me
    LDA PLAYER_X,X
    CLC
    ADC $E3
    STA PLAYER_X,X
nomovepush:    
    RTS                                 ;
;----------------------------------------


;----------------------------------------
; GRAVITY
;
; Gravity increases PLAYER_V by 1 unless
; the player collides with the ground.
;----------------------------------------
gravity:
    LDX CURRENT_V
    BEQ skipgravity
    CLC
    LDA CURRENT_Y
    ADC CURRENT_V
    STA $FF
    CPX #7
    BEQ notagain
    INX
    BNE notagain
    INX
notagain:
    STX CURRENT_V
    
    ; check to see if we hit a surface
    LDY $FF
    LDX CURRENT_X
    JSR collision
    CMP #0 ; if equal, no collision
    BNE nogravity
    LDA $FF
    STA CURRENT_Y
    RTS
nogravity:
    LDA CURRENT_V
    BPL uuup
    LDA CURRENT_Y
    ADC #4
    STA $FF
  uuup:
    LDA #0
    STA CURRENT_V
    LDA $FF
    AND #%11111000
    STA CURRENT_Y
    DEC CURRENT_Y
    RTS
; This checks below to see if there is empty to fall into.
skipgravity:
    LDA CURRENT_Y
    CLC
    ADC #2
    TAY
    LDX CURRENT_X
    JSR collision
    CMP #0
    BNE onfloor
    LDA #1
    STA CURRENT_V
onfloor:
    RTS
;----------------------------------------


;----------------------------------------
; COLLISION
;
; This function returns True if there is
; a collision with the playfield at
; X, Y (registers). This will check the
; tile we're in as well as the tile to the
; right and to the bottom. Returns a 0
; value if empty and a non-zero if full.
; Destroys X and Y.
;----------------------------------------
collision:                              ;
    .define ignore_me=$C9
    .define collide_me=$C8
    STX $E6
    STY $E7
    LDA #0
    STA $EE
    STA $EF
    ; X contains X position (column)
    ; Y contains Y position (row)
    ; There are 30 rows, with 4 bytes each.
    ; Y goes from 0 to 240. Divide by 8
    ; to reach 0 to 30. Multiply by 4 to get
    ; the correct byte.
    TYA
    LSR A
    BCC ok1
    INC $EE
    ok1:
    LSR A
    BCC ok2
    INC $EE
    ok2:
    LSR A
    BCC ok3
    INC $EE
    ok3:
    ASL A
    ASL A
    STA $FE ; fe has the y memory location
    
    ; There are 32 columns. Each byte contains
    ; 8 columns (one per bit). First find the
    ; correct column id (divide by 8) then find
    ; the byte (divide again by 8)
    TXA
    LSR A
    BCC ok4
    INC $EF
    ok4:
    LSR A
    BCC ok5
    INC $EF
    ok5:
    LSR A
    BCC ok6
    INC $EF
    ok6:
    STA $FC  ; fc has the x tile
    STA $EE ; store the tile to verify offset
    LSR A
    LSR A
    LSR A   ; A has the memory offset
    CLC
    TAX
    ADC $FE ; Add the memory location 
    STA $FE ; $400+FE has the byte of the current area
    LDA $FC
    ; Now mod X by 8 to get the BIT
    AND #%00000111
    TAX

    
    LDA #%10000000
colliloop:
    CPX #0
    BEQ donecoli
    LSR A
    DEX
    JMP colliloop
donecoli:
    STA $FD ; $FE contains our byte. $FD contains our mask
    
    ; We check this bit.
    ; If EF, check one to the side
    ; If EE and EF, then check one below
    ; If EE, check one below
    
    ; if any of these bits are 1, we return !0. otherwise, zero.
    
    LDX $FE
    LDA $400,X
    AND $FD
    BNE collireport
    CLC
    ROR $FD
    BCC loadrighter
    INX
    ROR $FD
loadrighter:
    LDA $EF
    BEQ alignedx
    LDA $400,X
    AND $FD
    BNE collireport
alignedx:
    INX
    INX
    INX
    INX
    LDA $EE
    BEQ collireport
    LDA $EF
    BEQ alignedy
    LDA $400,X
    AND $FD
    BNE collireport
alignedy:
    CLC
    ROL $FD
    BCC loadlefter
    DEX
    ROL $FD
loadlefter:
    LDA $400,X
    AND $FD
    BNE collireport
collireport:
    CMP #0
    BEQ blockcollide
    LDA #$FE
    STA collide_me
    RTS             
blockcollide:                           ; This phase is where we check block/block
                                        ; collisions. X=$E6, Y=$E7
    CLC
    LDA $E6
    ADC #7
    STA $E6
    LDA $E7
    ADC #7
    STA $E7
    
    LDX #0
blkcolloop:
    CPX ignore_me
    BEQ endobcoloop
    LDA PLAYER_X,X
    CMP $E6
    BCS endobcoloop
    ADC #14
    CMP $E6
    BCC endobcoloop
    LDA PLAYER_Y,X
    CMP $E7
    BCS endobcoloop
    ADC #14
    CMP $E7
    BCC endobcoloop
    INX
    TXA
    STA collide_me
    RTS     
endobcoloop:
    INX
    CPX #$10
    BNE blkcolloop
    
    LDA #0
    STA collide_me
    RTS
;----------------------------------------




;----------------------------------------
; RENDER
;
; This subroutine handles rendering.
;----------------------------------------
render:
    LDX #0
    LDY #0
blocks:
    LDA PLAYER_Y,X
    STA $700,Y
    INY
    LDA PLAYER_S,X
    STA $700,Y
    INY
    LDA PLAYER_P,X
    STA $700,Y
    INY
    LDA PLAYER_X,X
    STA $700,Y
    INY
    INX
    CPX #$10
    BNE blocks


    LDA #$00                            ; Now pass the OAM parameters to the PPU
    STA OAMADDR                         ;   and do DMA
    LDA #$07                            ; Page 7 has our sprites.
    STA OAMDMA                          ; Start DMA
    RTS
;----------------------------------------





;----------------------------------------
; DIENOW
;
; This turns the player into a block
;----------------------------------------
dienow:
    LDX BLOCK_POINT
    LDA PLAYER_X
    STA PLAYER_X,X
    LDA PLAYER_Y
    STA PLAYER_Y,X
    LDA #18
    STA PLAYER_S,X
    LDA PLAYER_P
    STA PLAYER_P,X
    
    DEC BLOCK_POINT
    BNE dieflipper
    LDA #15
    STA BLOCK_POINT
dieflipper:
    
    LDA init_x
    STA PLAYER_X
    LDA init_y
    STA PLAYER_Y
    DEC PLAYER_P
    BPL samecolor
    LDA #3
    STA PLAYER_P
samecolor:    
    
    LDA #%1100
    STA NOISEVOL
    LDA #%11111000
    STA NOISELEN
    LDA #%10001000
    STA NOISEMODE
    
    RTS






;----------------------------------------
; LOAD_STAGE: This loads a stage from the
; memory address pointed to by $00F0 using
; indirect addressing.
; 
; Copies the stage into $0400-$04FF.
; Loads it into PPU nametable.
;----------------------------------------
.define stage_pointer=$F0               ;
.define init_x=$400+120
.define init_y=$400+136
.define init_s=$400+152
.define init_p=$400+168
load_stage:                             ;
;----------------------------------------
; First, we copy the stage to stage RAM.
;----------------------------------------   
    LDY #0                              ;
    STY PPUMASK
stage_loop:                             ;
    LDA (stage_pointer), Y              ;
    STA $0400, Y                        ;
    INY                                 ;
    BNE stage_loop                      ;
;----------------------------------------
; Now we read the new stage RAM to set
; up the VRAM and draw the playfield.
;----------------------------------------
    LDA PPUSTATUS
    LDA #$20                            ;
    STA PPUADDR                         ;
    LDA #0                              ;
    STA PPUADDR                         ; Start drawing on page $20 - the nametable
    LDY #0                              ; Y is outer loop, run until = 240
stage_dloop:                            ;
    LDX #8                              ; X is inner loop
    LDA $0400,Y                         ; Read from the RAM copy of the field
  bits_loop:                            ; Read all 8 bits
    ASL A                               ; Put leftmost bit in carry
    PHA                                 ; Save A
    LDA #0                              ; Get the sprite for air
    BCC draw_nowall                     ;
    LDA #16                             ; Get the sprite for a wall
  draw_nowall:                          ;
    STA PPUDATA                         ; Store the sprite in playfield
    PLA                                 ; Get the A value back
    DEX                                 ;
    BNE bits_loop                       ; 8 bits in a byte
    INY                                 ;
    CPY #120                            ; 120 * 8 = all we need
    BNE stage_dloop                     ;
;----------------------------------------
    LDX #$40
    LDA stage_pointer+1
    AND #3
    STA $CB
    ASL A
    ASL A
    ORA $CB
    ASL A
    ASL A
    ORA $CB
    ASL A
    ASL A
    ORA $CB
paletters:
    STA PPUDATA
    DEX
    BNE paletters

    
    LDA #10
    STA TIMER_HI
    LDA #60
    STA TIMER_LO

    LDA #15
    STA BLOCK_POINT
    
    ; Initialize player sprites and stuff
    LDY #0
charinit:
    LDA $400+120,Y
    STA $210,Y
    INY
    CPY #64
    BNE charinit
    
;----------------------------------------
; Get the next stage ready.
;----------------------------------------
    LDA stage_pointer+1
    CMP #<stagelast
    BNE norestart
    LDA #<stage1
    STA stage_pointer+1
    JMP okalmostthere
norestart:
    INC stage_pointer+1

okalmostthere:
;----------------------------------------
; Clean up and return.
;----------------------------------------
    LDA PPUSTATUS                       ;
    LDA #0                              ; Reset scroll latch
    STA PPUSCROLL                       ; Fix scrolling values
    STA PPUSCROLL                       ;
    LDA #%00011110
    STA PPUMASK
    RTS                                 ; Return
;----------------------------------------

.org $E000
stage0:
    .db %11111111,%11111111,%11111111,%11111111
    .db %11111111,%11111111,%11111111,%11111111
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11111111,%11111111,%11111111,%11111111
    .db %11111111,%11111111,%11111111,%11111111
    .db 30,70,80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .db 30,70,80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .db 17,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    .db  0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3


.org $E100
stage1:
.db %11111111,%11111111,%11111111,%11001111
    .db %11111111,%11111111,%11111111,%11001111
    .db %11000001,%00000000,%00000000,%00000011
    .db %11000001,%00000000,%00000000,%00000011
    .db %11000001,%00000000,%00000000,%00000011
    .db %11000001,%00000000,%00000000,%00000011
    .db %11000001,%00000000,%00000000,%00000011
    .db %11000001,%00000000,%00000000,%00000011
    .db %11000001,%00000000,%00000000,%11111111
    .db %11000001,%00000000,%00000000,%10000011
    .db %11000001,%00000000,%00000000,%10000011
    .db %11000001,%00000000,%00000000,%10000011
    .db %11000001,%00000000,%00000111,%10000011
    .db %11000001,%00000000,%00000100,%00000011
    .db %11000001,%00000000,%00000100,%00000011
    .db %11000001,%00000000,%00000100,%00000011
    .db %11000001,%00000000,%00111100,%00000011
    .db %11000001,%00000000,%00100000,%00000011
    .db %11000001,%00000000,%00100000,%00000011
    .db %11000001,%00000000,%00100000,%00000011
    .db %11000001,%00000001,%11100000,%00000011
    .db %11000001,%00000001,%00000000,%00000011
    .db %11000001,%00000001,%00000000,%00000011
    .db %11000001,%00000001,%00000000,%00000011
    .db %11000000,%00001111,%00000000,%00000011
    .db %11000000,%00001000,%00000000,%00000011
    .db %11000000,%00001000,%00000000,%00000011
    .db %11000000,%00001000,%00000000,%00000011
    .db %11111111,%11111111,%11111111,%11111111
    .db %11111111,%11111111,%11111111,%11111111
    .db 30,215,00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .db 30,30,00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .db 17,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    .db  0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3


.org $E200

    .db %11111111,%11111111,%11111111,%11000111
    .db %11111111,%11111111,%11111111,%11000111
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00111111
    .db %11000000,%00000000,%00000000,%11111111
    .db %11111111,%00001111,%00001111,%11111111
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11111111,%11111111,%11111111,%11111111
    .db %11111111,%11111111,%11111111,%11111111
    .db 30,120,178, 50, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .db 30,50,30, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .db 17,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    .db  0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3


.org $E300
    .db %11111111,%11111111,%11111111,%00011111
    .db %11111111,%11111111,%11111111,%00011111
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%11000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00011111
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000111,%11000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%11000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000111,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%11000001,%11111111,%11111111
    .db %11000000,%10000000,%00000000,%00000011
    .db %11000000,%10000000,%00000000,%00000011
    .db %11000000,%10000000,%00000000,%00000011
    .db %11000000,%10000000,%00000000,%00000011
    .db %11111111,%11111111,%11111111,%11111111
    .db %11111111,%11111111,%11111111,%11111111
    .db 30,70,00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .db 30,70,00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .db 17,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    .db  0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3


.org $E400
    .db %11111111,%11111111,%11111111,%11001111
    .db %11111111,%11111111,%11111111,%11001111
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00110011
    .db %11001000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000010,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%01000000,%00100000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000001,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11111111,%11111111,%11111111,%11111111
    .db %11111111,%11111111,%11111111,%11111111
    .db 30,80,111, 175, 150, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .db 30,30,30, 30, 30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .db 17,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    .db  0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3
    

.org $E500
stagelast:
    .db %11111111,%11111110,%01111111,%11111111
    .db %11111111,%11111110,%01111111,%11111111
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11001010,%11101010,%01010111,%01010011
    .db %11001010,%10101010,%01010010,%01110011
    .db %11000100,%10101010,%01110010,%01110011
    .db %11000100,%10101010,%01110010,%01110011
    .db %11000100,%11101110,%01110111,%01010011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%01000110,%01010111,%00000011
    .db %11000000,%01000101,%01010101,%00000011
    .db %11000000,%01000101,%01110111,%00000011
    .db %11000000,%01000101,%00010101,%00000011
    .db %11000000,%01110110,%00010111,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11000000,%00000000,%00000000,%00000011
    .db %11111111,%11111111,%11111111,%11111111
    .db %11111111,%11111111,%11111111,%11111111
    .db 125,20,50, 170, 200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .db 30,30,30, 30, 30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .db 17,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    .db  0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3


; ******************************************************
; STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP STOP
;
; Don't change any of the code underneath this line unless
; you know what you are doing. Unlike many computers, the
; NES has to have time to warm up before it can run code.
; This code will warm up the NES, clear out the memory,
; and put it in a known state so that you can write the
; important stuff up above.
;*******************************************************
.org $F000                              ;
RESET:                                  ;
        SEI                             ; Disable IRQs
        CLD                             ; Disable decimal mode (not on NES)
        LDX #$40                        ;
        STX FRAMECTRL                   ; Disable APU frame IRQ
        LDX #$FF                        ;
        TXS                             ; Set stack pointer to top of stack
        INX                             ; Set X to 0
        STX PPUCTRL                     ; Disable NMI
        STX PPUMASK                     ; Disable rendering
        STX DMCFREQ                     ; Disable DMC IRQs
vblankwait1:                            ; Wait for the first vertical blank to
        BIT PPUSTATUS                   ;    ensure PPU is ready.
        BPL vblankwait1                 ;
clrmem:                                 ; Zero out all memory
        LDA #$00                        ;
        STA $0000, x                    ;
        STA $0100, x                    ;
        STA $0200, x                    ;
        STA $0400, x                    ;
        STA $0500, x                    ;
        STA $0600, x                    ;
        STA $0700, x                    ;
        LDA #$FE                        ;
        STA $0300, x                    ;
        INX                             ;
        BNE clrmem                      ;
vblankwait2:                            ; After 2 vertical blanks, the PPU is
        BIT PPUSTATUS                   ;    is ready to go.
        BPL vblankwait2                 ;
;----------------------------------------
; Now we load our sprite palettes.
;----------------------------------------
        LDA PPUSTATUS                   ; read PPU status to reset the high/low latch
        LDA #$3F                        ;
        STA PPUADDR                     ; write the high byte of $3F00 address
        LDA #$00                        ;
        STA PPUADDR                     ; write the low byte of $3F00 address
        LDX #$00                        ; start out at 0
loadpalettes:                           ;
        LDA palette, x                  ; load data from address (palette + the value in x)
        STA PPUDATA                     ; write to PPU
        INX                             ; X = X + 1
        CPX #$20                        ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
        BNE loadpalettes                ; Branch to LoadPalettesLoop if compare was Not Equal to zero
                                        ; if compare was equal to 32, keep going down
;----------------------------------------
; Now load a blank background. We need to fill $1000 bytes from $2000 to $3000
;----------------------------------------
        LDA PPUSTATUS                   ; read PPU status to reset the high/low latch  
        LDA #$00                        ;
        STA PPUSCROLL                   ; Set the scrolling to 0
        STA PPUSCROLL                   ;
        JMP START                       ;
;----------------------------------------
; Here's the color palette.
;----------------------------------------
palette:                                ;
        .db $0F,$02,$12,$22             ;
        .db $0F,$06,$16,$26             ;
        .db $0F,$0B,$1B,$2B             ;
        .db $0F,$0C,$1C,$2C             ;
        .db $0F,$02,$12,$22             ;
        .db $0F,$06,$16,$26             ;
        .db $0F,$0B,$1B,$2B             ;
        .db $0F,$0C,$1C,$2C             ;
;----------------------------------------        
; Interrupt table - located in the last six bytes of memory.
;----------------------------------------
        .org $FFFA                      ; Interrupt table is last three words
        .dw NMI                         ; When an NMI happens (once per frame
                                        ;   if enabled, the draw loop)
        .dw RESET                       ; When the processor first turns on or
                                        ;   is reset, it will jump to RESET
        .dw 0                           ; External interrupt IRQ is not used
;----------------------------------------
; Define all of the memory locations in the memory map.
;----------------------------------------
        .define ZEROPAGE=$0000              ;
        .define STACK=$0100                 ;
        .define PPUCTRL=$2000               ;
        .define PPUMASK=$2001               ;
        .define PPUSTATUS=$2002             ;
        .define OAMADDR=$2003               ;
        .define OAMDATA=$2004               ;
        .define PPUSCROLL=$2005             ;
        .define PPUADDR=$2006               ;
        .define PPUDATA=$2007               ;
        .define SQ1VOL=$4000                ;
        .define SQ1SWEEP=$4001              ;
        .define SQ1LO=$4002                 ;
        .define SQ1HI=$4003                 ;
        .define SQ2VOL=$4004                ;
        .define SQ2SWEEP=$4005              ;
        .define SQ2LO=$4006                 ;
        .define SQ2HI=$4007                 ;
        .define TRILIN=$4008                ;
        .define TRILO=$400A                 ;
        .define TRIHI=$400B                 ;
        .define NOISEVOL=$400C              ;
        .define NOISEMODE=$400E             ;
        .define NOISELEN=$400F              ;
        .define DMCFREQ=$4010               ;
        .define DMCRAW=$4011                ;
        .define DMCSTART=$4012              ;
        .define DMCLEN=$4013                ;
        .define OAMDMA=$4014                ;
        .define SNDCHAN=$4015               ;
        .define CONTROL1=$4016              ;
        .define CONTROL2=$4017              ;
        .define FRAMECTRL=$4018             ;
        .define PRGROM=$8000                ;
;----------------------------------------

