JumpingControl:
  LDX isJumping
  CPX #$01
  BEQ JumpingControlDone

ReadA: 
  LDA buttons1       ; player 1 - A
  AND #%01000000  ; only look at bit 0
  BEQ ReadADone   ; branch to ReadADone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)

  LDX #$01
  STX isJumping
  
  LDX #$00
  STX jumpingTicks
  
  LDX #$00
  STX isGoingDown
  
  LDX #$05
  STX velocityY

GameStateActualizationDoneA:
ReadADone:        ; handling this button is done
JumpingControlDone:
  RTS

JumpingUp:
  LDX isJumping
  CPX #$00
  BEQ JumpingUpDone
  LDX isGoingDown
  CPX #$01
  BEQ JumpingUpDone
  
  
  
  LDX #$00
MoveSpriteUpLoop:
  LDA $0200, x       ; load sprite X position
  LDY velocityY

MoveSpriteUpVelocityLoop:
  SEC             ; make sure carry flag is set
  SBC #$01        ; A = A - 1
  DEY
  CPY #$00
  BNE MoveSpriteUpVelocityLoop

  STA $0200, x       ; save sprite X position
  INX
  INX
  INX
  INX
  CPX #$10
  BNE MoveSpriteUpLoop

JumpingUpOverCheck:
  INC jumpingTicks
  LDY jumpingTicks
  CPY #$02
  BNE JumpingUpDone
  
  LDY #$00
  STY jumpingTicks
  
  LDY velocityY
  DEY
  CPY #$00
  BNE JumpingUpOverCheckOver
  
  INY
  LDX #$01
  STX isGoingDown
JumpingUpOverCheckOver:
  STY velocityY

JumpingUpDone:
  RTS