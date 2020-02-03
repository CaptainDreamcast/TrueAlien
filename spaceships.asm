spaceship_tiles:
     ;vert tile attr horiz
  .db $74, $75

spaceship_y_level1:
     ;vert tile attr horiz
  .db $40, $70, $A0, $D0


InitSpaceShips:

LoadSpaceShipSprites:
  LDX #$04
  STX spaceShipAmount

						
  LDY #$00
  LDX #$00
LoadSpaceShipDataLoop:
  JSR RNG
  LDA randomValue
  STA spaceShipX, y

  LDA spaceship_y_level1, y
  CLC
  ADC #$08
  STA spaceShipY, y

  LDA #$00
  STA spaceShipCollected, y

  INX
  INX
  INY
  CPY spaceShipAmount  ; Compare X to hex $10, decimal 16
  BNE LoadSpaceShipDataLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
  


  LDX #$00              ; start at 0
  LDY #$00

LoadSpaceShipSpritesLoop11:

  LDA spaceship_y_level1, y
  STA $0270, x          ; store into RAM address ($0200 + x)
  STA $0274, x          ; store into RAM address ($0200 + x)
  LDA spaceship_tiles
  STA $0271, x          ; store into RAM address ($0200 + x)
  LDA (spaceship_tiles + 1)
  STA $0275, x          ; store into RAM address ($0200 + x)
  LDA #$00
  STA $0272, x          ; store into RAM address ($0200 + x)
  STA $0276, x          ; store into RAM address ($0200 + x)
  LDA spaceShipX, y
  STA $0273, x          ; store into RAM address ($0200 + x)
  CLC
  ADC #$08
  STA $0277, x          ; store into RAM address ($0200 + x)
  INX
  INX
  INX
  INX
  INX
  INX
  INX
  INX
  INY
  CPY spaceShipAmount  ; Compare X to hex $10, decimal 16
  BNE LoadSpaceShipSpritesLoop11   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
                        ; if compare was equal to 16, keep going dow
						




  LDA #$00
  STA spaceShipsCollected
  
  LDA spaceShipAmount
  STA spaceShipsCollectedInv
  JSR UpdateShipCollectionText
  
  RTS


SetSingleShipDisabled:

  LDA spaceShipsCollected
  CLC
  ADC #$01
  STA spaceShipsCollected
  
  LDA spaceShipsCollectedInv
  SEC            
  SBC #$01  
  STA spaceShipsCollectedInv
  JSR UpdateShipCollectionText
  
  LDA spaceShipsCollectedInv
  CMP #$00
  BNE SetSingleShipDisabledOverTestOver

  JSR InitTimer8
  JSR GotoNextLevel
  
SetSingleShipDisabledOverTestOver:
  
  LDA #$01
  STA spaceShipCollected, y
  
  LDA #$00
  LDX #$00
  STY temp1
FindSpaceShipDisableSpriteLoop:
  CMP temp1
  BEQ FindSpaceShipDisableSpriteLoopOver
  INX
  INX
  INX
  INX
  INX
  INX
  INX
  INX
  CLC
  ADC #$01
  JMP FindSpaceShipDisableSpriteLoop
FindSpaceShipDisableSpriteLoopOver:


  LDA #$FF
  STA $0270, x
  STA $0274, x

  RTS

UpdateSingleSpaceShipCollision:

  LDA spaceShipX, y
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
  BCS UpdateSingleSpaceShipCollisionDone

  LDA spaceShipX, y
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
  BCS UpdateSingleSpaceShipCollisionDone


  LDA spaceShipY, y
  STA temp1
  LDA playerY 
  SEC            
  SBC #$04        
  STA temp2
  LDA temp1
  LDA temp2
  STY temp3
  CMP temp1 ; player - sizeY > enemxY + sizeY -> skip
  BCS UpdateSingleSpaceShipCollisionDone
  
  
  LDA spaceShipY, y
  SEC            
  SBC #$04   
  STA temp1
  LDA playerY     
  STA temp2
  LDA temp1
  CMP temp2 ; player + sizeY < enemxY - sizeY -> skip
  BCS UpdateSingleSpaceShipCollisionDone
  
  JSR SetSingleShipDisabled

UpdateSingleSpaceShipCollisionDone:  
  RTS


UpdateSingleSpaceShip:
  LDA spaceShipCollected, y
  CMP #$01
  BEQ UpdateSingleSpaceShipDone
  JSR UpdateSingleSpaceShipCollision
UpdateSingleSpaceShipDone:
  RTS

UpdateSpaceships:
  LDY spaceShipAmount
UpdateSpaceShipsLoop:
  DEY  
  JSR UpdateSingleSpaceShip
  CPY #$00
  BNE UpdateSpaceShipsLoop


  RTS