  .inesprg 1   ; 1x 16KB PRG code
  .ineschr 1   ; 1x  8KB CHR data
  .inesmap 0   ; mapper 0 = NROM, no bank swapping
  .inesmir 1   ; background mirroring
  

  .include "variables.asm"

;; DECLARE SOME CONSTANTS HERE
STATETITLE     = $00  ; displaying title screen
STATEPLAYING   = $01  ; move paddles/ball, check for collisions
STATEGAMEOVER  = $02  ; displaying game over screen
  
RIGHTWALL      = $F4  ; when ball reaches one of these, do something
TOPWALL        = $20
BOTTOMWALL     = $E0
LEFTWALL       = $04
  
PADDLE1X       = $08  ; horizontal position for paddles, doesnt move
PADDLE2X       = $F0


    

  
 
  .include "gamelogic.asm"

  .include "titlescreen.asm"
  .include "winningscreen.asm"
  .include "gamescreen.asm"
  .include "gameoverscreen.asm"
  .include "ui.asm"
  .include "util.asm"



 
;;;;;;;;;;;;;;  


TicksUpdate:
  INC ticks
  LDX ticks
  CPX #$10
  BNE FrameUpdateDone
  LDX #$00
  STX ticks
  INC whichFrame
  LDX whichFrame
  CPX #$02
  BNE FrameResetDone
  LDX #$00
  STX whichFrame
FrameResetDone:
  LDX #$0D
  LDA sprites_player, x
  CLC
  ADC whichFrame
  STA $0200, x
FrameUpdateDone:
  RTS

LatchController:
  LDA #$02
  STA $4016
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016       ; tell both the controllers to latch buttons

  LDA $4016
  LDA $4016
  LDA $4016
  LDA $4016
  LDA $4016
  LDA $4016
  RTS

ReadController1:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016
  LDX #$08
ReadController1Loop:
  LDA $4016
  LSR A            ; bit0 -> Carry
  ROL buttons1     ; bit0 <- Carry
  DEX
  BNE ReadController1Loop
  RTS
  
ReadController2:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016
  LDX #$08
ReadController2Loop:
  LDA $4017
  LSR A            ; bit0 -> Carry
  ROL buttons2     ; bit0 <- Carry
  DEX
  BNE ReadController2Loop
  RTS  

PPUCleanUp:
  ;;This is the PPU clean up section, so rendering the next frame starts properly.
  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000
  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001
  LDA #$00        ;;tell the ppu there is no background scrolling
  STA $2005
  STA $2005
  RTS

  
  
GatherPlayerPosition:
  LDA $0200
  CLC
  ADC #$10
  STA playerY
  
  LDA $0203
  CLC
  ADC #$08
  STA playerX

  rts
  
TileGather:
  LDA $0200
  LSR A
  LSR A
  LSR A
  sta temp1
  INC temp1
  INC temp1
  LDA $0203
  CLC
  ADC #$08
  LSR A
  LSR A
  LSR A
  sta temp2
 
  LDA #$00
  STA pointerLow
  LDA #$E2
  STA pointerHigh
  
  LDX temp1
  CPX #$00
  BEQ SelectTileLoopDone1
SelectTileLoop1:
  LDA #$07
  CMP temp1
  BCS SelectTileLoopDone1
  INC pointerHigh
  LDX temp1
  DEX
  DEX
  DEX
  DEX
  DEX
  DEX
  DEX
  DEX
  STX temp1
  JMP SelectTileLoop1
SelectTileLoopDone1:

  CLC

SelectTileLoop2:
  TXA
  CMP #$00
  BEQ SelectTileLoopDone2
  LDA pointerLow
  CLC
  ADC #$20
  STA pointerLow
  DEX
  JMP SelectTileLoop2
SelectTileLoopDone2:

  LDA pointerLow
  CLC
  ADC temp2
  STA pointerLow
  LDY #$00
  LDA [pointerLow], y
  STA tileBelow

TileGatherDone:
  RTS
  
  
TileGather2:
  LDA $0200
  LSR A
  LSR A
  LSR A
  sta temp1
  INC temp1
  LDA $0203
  CLC
  ADC #$08
  LSR A
  LSR A
  LSR A
  sta temp2
 
  LDA #$00
  STA pointerLow
  LDA #$E2
  STA pointerHigh
  
  LDX temp1
  CPX #$00
  BEQ SelectTileLoopDone12
SelectTileLoop12:
  LDA #$07
  CMP temp1
  BCS SelectTileLoopDone12
  INC pointerHigh
  LDX temp1
  DEX
  DEX
  DEX
  DEX
  DEX
  DEX
  DEX
  DEX
  STX temp1
  JMP SelectTileLoop12
SelectTileLoopDone12:

  CLC

SelectTileLoop22:
  TXA
  CMP #$00
  BEQ SelectTileLoopDone22
  LDA pointerLow
  CLC
  ADC #$20
  STA pointerLow
  DEX
  JMP SelectTileLoop22
SelectTileLoopDone22:

  LDA pointerLow
  CLC
  ADC temp2
  STA pointerLow
  LDY #$00
  LDA [pointerLow], y
  STA tileBehind

TileGatherDone2:
  RTS

LandingCheck:
  LDX tileBelow
  CPX #$B1
  BEQ LandingCheckSet

  LDX tileBehind
  CPX #$B2
  BEQ LandingCheckDone
  
  CPX #$B3
  BEQ LandingCheckDone
  
  LDX tileBelow
  CPX #$B2
  BEQ LandingCheckSet
  
  LDX tileBelow
  CPX #$B3
  BEQ LandingCheckSet

  JMP LandingCheckDone
LandingCheckSet:
  LDX #$0
  STX isJumping

LandingCheckDone:
  RTS

JumpingDown:
  LDX isJumping
  CPX #$00
  BEQ JumpingDownDone
  LDX isGoingDown
  CPX #$00
  BEQ JumpingDownDone
    
  JSR LandingCheck
  LDX isJumping
  CPX #$00
  BEQ JumpingDownDone

	
  LDX #$00
MoveSpriteDownLoop:
  LDA $0200, x       ; load sprite X position
  LDY velocityY

MoveSpriteDownVelocityLoop:
  CLC             ; make sure the carry flag is clear
  ADC #$01        ; A = A + 1
  DEY
  CPY #$00
  BNE MoveSpriteDownVelocityLoop

  STA $0200, x       ; save sprite X position
  INX
  INX
  INX
  INX
  CPX #$10
  BNE MoveSpriteDownLoop

JumpingDownOverCheck:
  LDY velocityY  
  CPY #$03
  BEQ JumpingDownOverCheckOver
  INY
JumpingDownOverCheckOver:
  STY velocityY

JumpingDownDone:
  RTS



Jumping:
  LDX isPlayerDead
  CPX #$01
  BEQ JumpingDone

  JSR JumpingControl
  JSR JumpingUp
  JSR JumpingDown
JumpingDone:
  RTS

FallingCheck:
  LDX isPlayerDead
  CPX #$01
  BEQ FallingCheckActive

  LDX isJumping
  CPX #$00
  BNE FallingCheckDone

  LDX isOnLadder
  CPX #$00
  BNE FallingCheckDone

  LDX tileBelow
  CPX #$B0
  BNE FallingCheckDone

FallingCheckActive:
  LDX #$1
  STX isJumping
  LDX #$0
  STX velocityY
  LDX #$1
  STX isGoingDown
FallingCheckDone:
  RTS

  .include "ladder.asm"
  .include "enemies.asm"  
  .include "dying.asm"
  .include "spaceships.asm"
  .include "background.asm"
  




GameOverScreen:
  ;;This is the PPU clean up section, so rendering the next frame starts properly.
  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000
  LDA #%00000000   ; enable sprites, enable background, no clipping on left side
  STA $2001
  LDA #$00        ;;tell the ppu there is no background scrolling
  STA $2005
  STA $2005
  
  RTS

;;;;  
  
  
  .bank 1
  .org $E000
palette:
  .db $0F,$0F,$15,$30,  $22,$36,$17,$0F,  $22,$30,$21,$0F,  $22,$27,$17,$0F   ;;background palette
  .db $22,$1C,$1A,$1A,  $22,$02,$38,$3C,  $22,$1C,$15,$14,  $22,$02,$38,$3C   ;;sprite palette

sprites_player:
     ;vert tile attr horiz
  .db $68, $00, $00, $80   ;sprite 0
  .db $68, $01, $00, $88   ;sprite 1
  .db $70, $10, $00, $80   ;sprite 2
  .db $70, $11, $00, $88   ;sprite 3

  .org $E200
background:

  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 1
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky

  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 2
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky

  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 3
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky

  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 4
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky

  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 5
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky

  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 6
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky

  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 7
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky

  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 8
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky

  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 9
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky

  .db $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B2,$B3,$B1,$B1,$B1,$B1,$B1,$B1  ;;row 10
  .db $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1  ;;all sky

  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B2,$B3,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 11
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky

  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B2,$B3,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 12
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky

  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B2,$B3,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 13
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky

  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B2,$B3,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 14
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky

  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B2,$B3,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 15
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky

  .db $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1  ;;row 16
  .db $B1,$B1,$B1,$B2,$B3,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1  ;;all sky

  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 17
  .db $B0,$B0,$B0,$B2,$B3,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky

  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 18
  .db $B0,$B0,$B0,$B2,$B3,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky

  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 19
  .db $B0,$B0,$B0,$B2,$B3,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky

  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 20
  .db $B0,$B0,$B0,$B2,$B3,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky

  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 21
  .db $B0,$B0,$B0,$B2,$B3,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky

  .db $B1,$B2,$B3,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1  ;;row 22
  .db $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B2,$B3,$B1,$B1  ;;all sky

  .db $B0,$B2,$B3,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 23
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B2,$B3,$B0,$B0  ;;all sky

  .db $B0,$B2,$B3,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 24
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B2,$B3,$B0,$B0  ;;all sky

  .db $B0,$B2,$B3,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 25
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B2,$B3,$B0,$B0  ;;all sky

  .db $B0,$B2,$B3,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 26
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B2,$B3,$B0,$B0  ;;all sky

  .db $B0,$B2,$B3,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 27
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B2,$B3,$B0,$B0  ;;all sky

  .db $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1  ;;row 28
  .db $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1  ;;all sky

  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 29
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky
  
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;row 30
  .db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0  ;;all sky  
  
attribute:
  .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000

  .db $24,$24,$24,$24, $47,$47,$24,$24 ,$47,$47,$47,$47, $47,$47,$24,$24 ,$24,$24,$24,$24 ,$24,$24,$24,$24, $24,$24,$24,$24, $55,$56,$24,$24  ;;brick bottoms


  .org $E700
  .include "titlebg.asm"

  .org $EC00
  .include "gameoverbg.asm"
  
  .org $F100
  .include "winningbg.asm"


  .org $FFFA     ;first of the three vectors starts here
  .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                   ;processor will jump to the label NMI:
  .dw RESET      ;when the processor first turns on or is reset, it will jump
                   ;to the label RESET:
  .dw 0          ;external interrupt IRQ is not used in this tutorial
  
  
;;;;;;;;;;;;;;  
  
  
  .bank 2
  .org $0000
  .incbin "TrueAliens.chr"   ;includes 8KB graphics file from SMB1  
  .incbin "Title.chr"   ;includes 8KB graphics file from SMB1