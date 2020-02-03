PlayerDyingFallingDown:

  LDX #$00
PlayerDyingFallingDownMoveSprite:
  LDA $0200, x       ; load sprite X position
  LDY #$02
PlayerDyingFallingDownVelocity:
  CLC             ; make sure the carry flag is clear
  ADC #$01        ; A = A + 1
  DEY
  CPY #$00
  BNE PlayerDyingFallingDownVelocity

  STA $0200, x       ; save sprite X position
  INX
  INX
  INX
  INX
  CPX #$10
  BNE PlayerDyingFallingDownMoveSprite

  RTS

PlayerDyingExit:
  LDA #$F8
  CMP playerY
  BCS PlayerDyingExitDone
  
  LDA #$01
  STA isScreenDone

PlayerDyingExitDone:
  RTS

PlayerDying:
  LDX isPlayerDead
  CPX #$01
  BNE PlayerDyingDone

  LDX isScreenDone
  CPX #$01
  BEQ PlayerDyingDone

  JSR PlayerDyingFallingDown
  JSR PlayerDyingExit
  
  
PlayerDyingDone:
  RTS