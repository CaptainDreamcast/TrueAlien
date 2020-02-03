LoadGameOverBackground:
  LDX #$00
  STX $2000    ; disable NMI
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs

vblankwait21:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwait21

  LDA #$EC
  STA temp1
  JSR LoadBackground
    
vblankwait22:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwait22

  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000

  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001
	
  RTS

InitGameOverScreen:
  JSR ClearSprites
  JSR LoadGameOverBackground
  
  LDA #$03
  STA currentScreen
  
  RTS
  
  
UpdateGameOverScreenFinished:
  LDA buttons1       ; player 1 - A
  AND #%01000000  ; only look at bit 0
  BEQ ReadGameOverADone   ; branch to ReadADone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)

  JSR InitTitleScreen

ReadGameOverADone:        ; handling this button is done

  RTS
  
UpdateGameOverScreen:
  JSR LatchController
  JSR ReadController1
  JSR ReadController2
  JSR UpdateGameOverScreenFinished
  JSR PPUCleanUp
  RTS
  
  
  
  
  
  
