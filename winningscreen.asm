LoadWinningBackground:
  LDX #$00
  STX $2000    ; disable NMI
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs

vblankwaitWinning21:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwaitWinning21

  LDA #$F1
  STA temp1
  JSR LoadBackground
    
vblankwaitWinning22:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwaitWinning22

  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000

  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001
	
  RTS

InitLifeSprites:
  LDA #$68
  STA $208
  LDA liveAmount
  CLC
  ADC #$C0
  STA $209
  LDA #$00
  STA $20A
  LDA #$90
  STA $20B
  RTS
  
InitLevelSprites:
  LDA #$58
  STA $200
  LDA currentLevelHigh
  CLC
  ADC #$C0
  STA $201
  LDA #$00
  STA $202
  LDA #$90
  STA $203
  
  LDA #$58
  STA $204
  LDA currentLevelLow
  CLC
  ADC #$C0
  STA $205
  LDA #$00
  STA $206
  LDA #$98
  STA $207
  
  RTS

InitWinningScreen:
  JSR ClearSprites
  JSR LoadWinningBackground
  JSR InitLifeSprites
  JSR InitLevelSprites
  
  LDA #$01
  STA currentScreen
  
  LDA #$00
  STA winningTicks
  
  RTS
  
IncreaseLevel:
  LDA currentLevelLow
  STA arg1
  LDA currentLevelHigh
  STA arg2
  JSR IncreaseTimer
  LDA out1
  STA currentLevelLow
  LDA out2
  STA currentLevelHigh
  RTS
  
GotoNextLevel:
  
  JSR IncreaseLevel
  JSR InitWinningScreen
  RTS
  
  
UpdateWinningScreenFinished:
  LDA buttons1       ; player 1 - A
  AND #%01000000  ; only look at bit 0
  BEQ ReadWinningADone   ; branch to ReadADone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)

  JSR InitGameScreen

ReadWinningADone:        ; handling this button is done

  INC winningTicks
  LDA winningTicks
  CMP #$80
  BNE UpdateWinningScreenFinishedOver

  JSR InitGameScreen

UpdateWinningScreenFinishedOver:

  RTS
  
UpdateWinningScreen:
  JSR LatchController
  JSR ReadController1
  JSR ReadController2
  JSR UpdateWinningScreenFinished
  JSR PPUCleanUp
  RTS
  
  
  
  
  
  
