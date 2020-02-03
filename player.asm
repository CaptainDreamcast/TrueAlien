UpdatePlayerSpritesJumping2:
  LDA #$04
  STA $0201 
  LDA #$05
  STA $0205 
  LDA #$14
  STA $0209 
  LDA #$15
  STA $020D 
  LDA #%00000000
  STA $0202
  STA $0206
  STA $020A
  STA $020E
  RTS


UpdatePlayerSpritesStanding2:
  LDA #$00
  STA $0201 
  LDA #$01
  STA $0205 
  LDA #$10
  STA $0209 
  LDA #$11
  STA $020D 
  LDA #%00000000
  STA $0202
  STA $0206
  STA $020A
  STA $020E
  RTS

UpdatePlayerSpritesClimbing2:

  LDA buttons1       ; player 1 - A
  AND #%00000100  ; only look at bit 0
  BNE IncreaseClimbingTicks   ; branch to ReadADone if button is pressed (1)
                  ; add instructions here to do something when button IS pressed (1)
  LDA buttons1       ; player 1 - A
  AND #%00001000  ; only look at bit 0
  BNE IncreaseClimbingTicks   ; branch to ReadADone if button is pressed (1)
                  ; add instructions here to do something when button IS pressed (1)
    
  
  JMP IncreaseClimbingTicksDone
IncreaseClimbingTicks:
  LDA playerTicks
  CMP #$08
  BNE UpdatePlayerSpritesTicksDone
  LDA #$00
  STA playerTicks
  JMP IncreaseClimbingTicksDone
UpdatePlayerSpritesTicksDone:
  CLC 
  ADC #$01
  STA playerTicks
IncreaseClimbingTicksDone:

  LDA playerTicks
  LSR A
  LSR A
  CMP #$00
  BEQ ClimbingSprites2

  LDA #$06
  STA $0201 
  LDA #$07
  STA $0205 
  LDA #$16
  STA $0209 
  LDA #$17
  STA $020D 
  LDA #%00000000
  STA $0202
  STA $0206
  STA $020A
  STA $020E
  
  JMP ClimbingSpritesDone
ClimbingSprites2:

  LDA #$07
  STA $0201 
  LDA #$06
  STA $0205 
  LDA #$17
  STA $0209 
  LDA #$16
  STA $020D 
  LDA #%01000000
  STA $0202
  STA $0206
  STA $020A
  STA $020E
  
ClimbingSpritesDone:  
  RTS


UpdatePlayerSpritesMovement2:

  LDA buttons1       ; player 1 - A
  AND #%00000010  ; only look at bit 0
  BNE IncreaseMovementTicks   ; branch to ReadADone if button is pressed (1)
                  ; add instructions here to do something when button IS pressed (1)
  LDA buttons1       ; player 1 - A
  AND #%00000001  ; only look at bit 0
  BNE IncreaseMovementTicks   ; branch to ReadADone if button is pressed (1)
                  ; add instructions here to do something when button IS pressed (1)
    
  
  JMP UpdatePlayerSpritesStanding1
IncreaseMovementTicks:
  LDA playerTicks
  CMP #$08
  BNE UpdatePlayerMovementTicksDone
  LDA #$00
  STA playerTicks
  JMP IncreaseMovementTicksDone
UpdatePlayerMovementTicksDone:
  CLC 
  ADC #$01
  STA playerTicks
IncreaseMovementTicksDone:

  LDA playerTicks
  LSR A
  LSR A
  CMP #$00
  BEQ MovementSprites2

  LDA #$02
  STA $0201 
  LDA #$03
  STA $0205 
  LDA #$12
  STA $0209 
  LDA #$13
  STA $020D 
  LDA #%00000000
  STA $0202
  STA $0206
  STA $020A
  STA $020E
  
  JMP MovementSpritesDone
MovementSprites2:

  LDA #$03
  STA $0201 
  LDA #$02
  STA $0205 
  LDA #$13
  STA $0209 
  LDA #$12
  STA $020D 
  LDA #%01000000
  STA $0202
  STA $0206
  STA $020A
  STA $020E
  
  JMP MovementSpritesDone
UpdatePlayerSpritesStanding1:
  JSR UpdatePlayerSpritesStanding2
  JMP MovementSpritesDone  
  
  
MovementSpritesDone:  
  RTS


UpdatePlayerSprites:

  LDA isJumping
  CMP #$01
  BEQ UpdatePlayerSpritesJumping1
  
  LDA isOnLadder
  CMP #$01
  BEQ UpdatePlayerSpritesClimbing1
  
  
  JMP UpdatePlayerSpritesMovement1
  
UpdatePlayerSpritesJumping1:
  JSR UpdatePlayerSpritesJumping2
  JMP UpdatePlayerSpritesDone
  
UpdatePlayerSpritesClimbing1:
  JSR UpdatePlayerSpritesClimbing2
  JMP UpdatePlayerSpritesDone
  
UpdatePlayerSpritesMovement1:
  JSR UpdatePlayerSpritesMovement2
  JMP UpdatePlayerSpritesDone


UpdatePlayerSpritesDone:
  RTS