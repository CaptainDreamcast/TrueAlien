
BackgroundWalkTilesY:
  .db $09, $0F, $15, $1A
BackgroundWalkTilesYEnd:

BackgroundWalkPosY:
  .db $09 * 8, $0F * 8, $15 * 8, $1A * 8

  .org $D000
  
IncreasePointerByRow:
  LDA VariableLocation
  LDA BgBufferLocation
  LDA bgBuffer
  LDA bgBufferEnd

  LDA pointerLow
  CMP #$E0
  BNE IncreasePointerByRowNoHighIncrease
  
  LDA #$00
  STA pointerLow
  INC pointerHigh

  JMP IncreasePointerByRowOver
IncreasePointerByRowNoHighIncrease: 
  LDA pointerLow
  CLC
  ADC #$20
  STA pointerLow
IncreasePointerByRowOver:
  RTS

FindSetLadder:
  LDA #$20
  STA pointerHigh
  LDA #$00
  STA pointerLow
  
  
  LDX arg2
FindSetLadderBeginningLoop:
  CPX #$00
  BEQ FindSetLadderBeginningLoopEnd

  STX temp3
  JSR IncreasePointerByRow  
  LDX temp3

  DEX
  JMP FindSetLadderBeginningLoop
FindSetLadderBeginningLoopEnd:  
  
  LDA pointerLow
  CLC
  ADC arg1
  STA pointerLow
  
  
  LDY #$00
SetLadderLoop:
  
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA pointerHigh
  STA $2006             ; write the high byte of $2000 address
  LDA pointerLow
  STA $2006             ; write the low byte of $2000 address

  LDA #$B2
  STA $2007             ; write the low byte of $2000 address
  LDA #$B3
  STA $2007             ; write the low byte of $2000 address

  STY temp3
  JSR IncreasePointerByRow
  LDY temp3

  INY
  CPY #$08
  BNE SetLadderLoop
  

  RTS


LoadRandomLadder:
  LDY #$00
LoadRandomLadderLoop:
  JSR RNGTileX
  LDA out1
  STA arg1
  LDA BackgroundWalkTilesY, y
  STA arg2
  STY temp4
  JSR FindSetLadder
  LDY temp4
  
  INY
  CPY #$01
  BNE LoadRandomLadderLoop


  RTS

LoadGameScreenBackground:
  LDX #$00
  STX $2000    ; disable NMI
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs

vblankwaitGameScreen1:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwaitGameScreen1

  LDA #$E2
  STA temp1
  JSR LoadBackground
  ;JSR LoadRandomLadder
    
vblankwaitGameScreen2:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwaitGameScreen2

  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000

  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001
	
  RTS