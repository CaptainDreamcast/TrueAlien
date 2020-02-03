  .bank 0
  .org $C000 
RESET:
  SEI          ; disable IRQs
  CLD          ; disable decimal mode
  LDX #$40
  STX $4017    ; disable APU frame IRQ
  LDX #$FF
  TXS          ; Set up stack
  INX          ; now X = 0
  STX $2000    ; disable NMI
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs

vblankwait1:       ; First wait for vblank to make sure PPU is ready
  BIT $2002
  BPL vblankwait1

  clrmem:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0300, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0200, x
  INX
  BNE clrmem
   
vblankwait2:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwait2

LoadPalettes:
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA #$3F
  STA $2006             ; write the high byte of $3F00 address
  LDA #$00
  STA $2006             ; write the low byte of $3F00 address
  LDX #$00              ; start out at 0
LoadPalettesLoop:
  LDA palette, x        ; load data from address (palette + the value in x)
                          ; 1st time through loop it will load palette+0
                          ; 2nd time through loop it will load palette+1
                          ; 3rd time through loop it will load palette+2
                          ; etc
  STA $2007             ; write to PPU
  INX                   ; X = X + 1
  CPX #$20              ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
  BNE LoadPalettesLoop  ; Branch to LoadPalettesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down
                  ; if compare was equal to 16, keep going down
              
  LDA #$E2
  STA temp1              
  JSR LoadBackground              
        
              
LoadAttribute:
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA #$23
  STA $2006             ; write the high byte of $23C0 address
  LDA #$C0
  STA $2006             ; write the low byte of $23C0 address
  LDX #$00              ; start out at 0
LoadAttributeLoop:
  LDA attribute, x      ; load data from address (attribute + the value in x)
  STA $2007             ; write to PPU
  INX                   ; X = X + 1
  CPX #$08              ; Compare X to hex $08, decimal 8 - copying 8 bytes
  BNE LoadAttributeLoop  ; Branch to LoadAttributeLoop if compare was Not Equal to zero
                        ; if compare was equal to 128, keep going down

              
              
              
  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000

  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001

  LDA #$05
  STA randomValue
  JSR ResetGame
  JSR InitTitleScreen

Forever:
  JMP Forever     ;jump back to Forever, infinite loop


; temp1 high pointer
LoadBackground:
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA #$20
  STA $2006             ; write the high byte of $2000 address
  LDA #$00
  STA $2006             ; write the low byte of $2000 address
  LDA #$00
  STA pointerLow
  LDA temp1
  STA pointerHigh

  LDX #$00              ; start out at 0
  LDY #$00
LoadBackgroundLoopX:
LoadBackgroundLoopY:
  LDA [pointerLow], y     ; load data from address (background + the value in x)
  STA $2007             ; write to PPU
  INY                   ; X = X + 1
  CPX #$03
  BEQ LoadBackgroundFinalRouteY
  CPY #$00
  BNE LoadBackgroundLoopY
  JMP LoadBackgroundLoopYOver
LoadBackgroundFinalRouteY:
  CPY #$C0
  BNE LoadBackgroundLoopY
LoadBackgroundLoopYOver:
  INC pointerHigh
  INX
  CPX #$04
  BNE LoadBackgroundLoopX      
  
  RTS
  


clrmemfunc:
  LDX #$00
clrmem2:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0300, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0200, x
  INX
  BNE clrmem2
  
  RTS

ClearSprites:
  LDX #$00
  LDA #$FE
ClearSpritesLoop:
  STA $0200, x
  INX
  BNE ClearSpritesLoop
  RTS

NMI:
UpdateGame:
  LDA #$00
  STA $2003       ; set the low byte (00) of the RAM address
  LDA #$02
  STA $4014       ; set the high byte (02) of the RAM address, start the transfer

  JSR RNG

  LDX currentScreen

  CPX #$00
  BEQ UpdateGameTitleScreen

  CPX #$01
  BEQ UpdateGameWinningScreen
  
  CPX #$02
  BEQ UpdateGameGameScreen
  
  CPX #$03
  BEQ UpdateGameGameOverScreen

UpdateGameTitleScreen:
  JSR UpdateTitleScreen
  JMP FrameFinish

UpdateGameWinningScreen:
  JSR UpdateWinningScreen
  JMP FrameFinish
  
UpdateGameGameScreen:
  JSR UpdateGameScreen
  JMP FrameFinish
  
UpdateGameGameOverScreen:
  JSR UpdateGameOverScreen
  JMP FrameFinish

FrameFinish:  
  RTI             ; return from interrupt