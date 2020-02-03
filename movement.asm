Movement:
  LDX isPlayerDead
  CPX #$01
  BEQ MovementDone


ReadLeft: 
  LDA buttons1       ; player 1 - B
  AND #%00000010  ; only look at bit 0
  BEQ ReadLeftDone   ; branch to ReadBDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
  JSR TicksUpdate
  LDX #$00
MoveSpriteLeftLoop:
  LDA $0203, x       ; load sprite X position
  SEC             ; make sure carry flag is set
  SBC #$02        ; A = A - 1
  STA $0203, x       ; save sprite X position
  INX
  INX
  INX
  INX
  CPX #$10
  BNE MoveSpriteLeftLoop

GameStateActualizationDoneLeft:
ReadLeftDone:        ; handling this button is done

ReadRight: 
  LDA buttons1      ; player 1 - A
  AND #%00000001  ; only look at bit 0
  BEQ ReadRightDone   ; branch to ReadADone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)

  JSR TicksUpdate
  LDX #$00
MoveSpriteRightLoop:
  LDA $0203, x       ; load sprite X position
  CLC             ; make sure the carry flag is clear
  ADC #$02        ; A = A + 1
  STA $0203, x       ; save sprite X position
  INX
  INX
  INX
  INX
  CPX #$10
  BNE MoveSpriteRightLoop
 
GameStateActualizationDoneRight:
ReadRightDone:        ; handling this button is done
MovementDone:
  RTS