sprites_enemy:
     ;vert tile attr horiz
  .db $70, $71

pos_enemies_y_level1:
     ;vert tile attr horiz
  .db $40, $70, $A0, $D0

; per enemy
enemy_going_left:
     ;vert tile attr horiz
  .db $01, $00, $01, $00


InitEnemies:

LoadEnemySprites:

  LDX #$04
  STX enemyAmount

  LDY #$00
  LDX #$00
LoadEnemyDataLoop:
  
  JSR RNG
  LDA randomValue
  STA enemyX, y
  LDA pos_enemies_y_level1, y
  CLC
  ADC #$08
  STA enemyY, y
  LDA enemy_going_left, y
  STA enemyGoingLeft, y
  JSR RNG
  LDA randomValue
  LSR A
  STA enemyLeftX, y
  JSR RNG
  LDA randomValue
  LSR A
  CLC
  ADC #$80
  STA enemyRightX, y
  LDA #$00
  STA enemyTicks, y

  INX
  INX
  INY
  CPY enemyAmount  ; Compare X to hex $10, decimal 16
  BNE LoadEnemyDataLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero




  LDX #$00              ; start at 0
  LDY #$00

LoadEnemySpritesLoop11:

  LDA pos_enemies_y_level1, y
  STA $0210, x          ; store into RAM address ($0200 + x)
  STA $0214, x          ; store into RAM address ($0200 + x)
  LDA sprites_enemy
  STA $0211, x          ; store into RAM address ($0200 + x)
  LDA (sprites_enemy + 1)
  STA $0215, x          ; store into RAM address ($0200 + x)
  LDA #$00
  STA $0212, x          ; store into RAM address ($0200 + x)
  STA $0216, x          ; store into RAM address ($0200 + x)
  LDA enemyX, y
  STA $0213, x          ; store into RAM address ($0200 + x)
  CLC
  ADC #$08
  STA $0217, x          ; store into RAM address ($0200 + x)
  INX
  INX
  INX
  INX
  INX
  INX
  INX
  INX
  INY
  CPY enemyAmount  ; Compare X to hex $10, decimal 16
  BNE LoadEnemySpritesLoop11   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
                        ; if compare was equal to 16, keep going dow
						


						

  


  
  
  RTS
  
  
UpdateSingleEnemyMovementLeft:
  LDA enemyX, y
  SEC             ; make sure carry flag is set
  SBC #$01        ; A = A - 1
  STA enemyX, y
  STA temp1	
  LDA enemyLeftX, y
  STA temp2
  LDA temp1
  CMP temp2
  BCS UpdateSingleEnemyMovementLeftDone
  LDA #$00
  STA enemyGoingLeft, y
 
UpdateSingleEnemyMovementLeftDone: 
  RTS
  
UpdateSingleEnemyMovementRight:
  LDA enemyX, y
  CLC
  ADC #$01
  STA enemyX, y
  
  STA temp1	
  LDA enemyRightX, y
  STA temp2
  LDA temp2
  CMP temp1
  BCS UpdateSingleEnemyMovementRightDone
  LDA #$01
  STA enemyGoingLeft, y
 
UpdateSingleEnemyMovementRightDone: 
  RTS
  
  
UpdateSingleEnemyMovement:
  LDA enemyGoingLeft, y
  CMP #$01
  BEQ UpdateSingleEnemyMovementLeftStart
  JSR UpdateSingleEnemyMovementRight
  JMP UpdateSingleEnemyMovementOver
UpdateSingleEnemyMovementLeftStart:
  JSR UpdateSingleEnemyMovementLeft
UpdateSingleEnemyMovementOver:
  RTS
  
  
  
UpdateSingleEnemyCollision:
  LDA invincibilityTicks
  CMP #$00
  BNE UpdateSingleEnemyCollisionDone

  LDA enemyX, y
  CLC
  ADC #$08
  CLC
  ADC #$04
  STA temp1
  LDA playerX 
  SEC            
  SBC #$04        
  STA temp2
  CMP temp1 ; player - sizeX > enemxX + sizeX -> skip
  BCS UpdateSingleEnemyCollisionDone

  LDA enemyX, y
  CLC
  ADC #$08
  SEC            
  SBC #$04 
  STA temp1
  LDA playerX 
  CLC
  ADC #$04      
  STA temp2
  LDA temp1
  CMP temp2 ; player + sizeX < enemxX - sizeX -> skip
  BCS UpdateSingleEnemyCollisionDone


  LDA enemyY, y
  STA temp1
  LDA playerY 
  SEC            
  SBC #$04        
  STA temp2
  LDA temp1
  LDA temp2
  STY temp3
  CMP temp1 ; player - sizeY > enemxY + sizeY -> skip
  BCS UpdateSingleEnemyCollisionDone
  
  
  LDA enemyY, y
  SEC            
  SBC #$04   
  STA temp1
  LDA playerY     
  STA temp2
  LDA temp1
  CMP temp2 ; player + sizeY < enemxY - sizeY -> skip
  BCS UpdateSingleEnemyCollisionDone
  
  
  LDA #$01
  STA isPlayerDead

UpdateSingleEnemyCollisionDone:  
  RTS
  
UpdateSingleEnemy:
  JSR UpdateSingleEnemyMovement
  JSR UpdateSingleEnemyCollision
  RTS
  
UpdateSingleEnemyActiveSprite:
  LDA enemyGoingLeft, y
  CMP #$00
  BEQ UpdateEnemySpritesSpritesUninverted
  
  LDA enemyTicks, y
  LSR A
  LSR A
  CMP #$00
  BEQ UpdateEnemySetInverted0
  LDA enemyX, y
  STA $0213, x
  JMP UpdateEnemySetInverted1

UpdateEnemySetInverted0:
  LDA #$71
  STA $0211, x 
  LDA #$70
  STA $0215, x 
  LDA #%01000000
  STA $0212, x
  STA $0216, x
  JMP UpdateEnemySpritesSpritesSetOver  
UpdateEnemySetInverted1:  
  LDA #$73
  STA $0211, x
  LDA #$72
  STA $0215, x 
  LDA #%01000000
  STA $0212, x
  STA $0216, x
  JMP UpdateEnemySpritesSpritesSetOver  

UpdateEnemySpritesSpritesUninverted:  

  LDA enemyTicks, y
  CMP #$00
  BEQ UpdateEnemySpritesSpritesSet0

  JMP UpdateEnemySpritesSpritesSet1

UpdateEnemySpritesSpritesSet0:  
  LDA #$70
  STA $0211, x
  LDA #$71
  STA $0215, x
  LDA #%00000000
  STA $0212, x
  STA $0216, x  
  JMP UpdateEnemySpritesSpritesSetOver  
UpdateEnemySpritesSpritesSet1:  
  LDA #$72
  STA $0211, x 
  LDA #$73
  STA $0215, x 
  LDA #%00000000
  STA $0212, x
  STA $0216, x

UpdateEnemySpritesSpritesSetOver:  
  RTS
  
UpdateEnemySprites:


  LDX #$00              ; start at 0
  LDY #$00

UpdateEnemySpritesLoop:
  LDA enemyX, y
  STA $0213, x          ; store into RAM address ($0200 + x)
  CLC
  ADC #$08
  STA $0217, x
  
  LDA enemyTicks, y
  CLC
  ADC #$01
  CMP #$08
  BNE UpdateEnemySpritesLoopTicksOver
  LDA #$00
  
UpdateEnemySpritesLoopTicksOver:
  STA enemyTicks, y
  
  JSR UpdateSingleEnemyActiveSprite

  INX
  INX
  INX
  INX
  INX
  INX
  INX
  INX
  INY
  CPY enemyAmount  ; Compare X to hex $10, decimal 16
  BNE UpdateEnemySpritesLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
                        ; if compare was equal to 16, keep going dow
  RTS
  
UpdateEnemies
  LDY enemyAmount
UpdateEnemiesLoop:
  DEY  
  JSR UpdateSingleEnemy
  CPY #$00
  BNE UpdateEnemiesLoop

  jsr UpdateEnemySprites

  RTS