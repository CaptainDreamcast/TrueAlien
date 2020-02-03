LoadTitleScreenBackground:
  LDX #$00
  STX $2000    ; disable NMI
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs

vblankwaitTitle21:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwaitTitle21

  LDA #$E7
  STA temp1
  JSR LoadBackground
    
vblankwaitTitle22:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwaitTitle22

  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000

  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001
	
  RTS

InitTitleScreen:
  JSR ClearSprites
  JSR LoadTitleScreenBackground
  
  LDA #$00
  STA currentScreen
  
  RTS
  
  
UpdateTitleScreenFinished:
  LDA buttons1       ; player 1 - A
  AND #%00010000  ; only look at bit 0
  BEQ ReadTitleADone   ; branch to ReadADone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)

  JSR ResetGame
  JSR GotoNextLevel

ReadTitleADone:        ; handling this button is done

  RTS
  
UpdateTitleScreen:
  JSR LatchController
  JSR ReadController1
  JSR ReadController2
  JSR UpdateTitleScreenFinished
  JSR PPUCleanUp
  RTS
  
  
  
  
  
  
