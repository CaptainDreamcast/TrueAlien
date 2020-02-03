
UpdateLadderUpEntry:
  LDX isOnLadder
  CPX #$00
  BNE UpdateLadderUpEntryDone

  LDA buttons1      ; player 1 - A
  AND #%00001000  ; only look at bit 0
  BEQ UpdateLadderUpEntryDone   
  LDY tileBelow
  LDX tileBehind
  CPX #$B2
  BEQ UpdateLadderUpEntrySetActive

  LDX tileBehind
  CPX #$B3
  BEQ UpdateLadderUpEntrySetActive

  JMP UpdateLadderUpEntryDone
UpdateLadderUpEntrySetActive:
  LDX #$01
  STX isOnLadder

UpdateLadderUpEntryDone:
  RTS
  
UpdateLadderDownEntry:
  LDX isOnLadder
  CPX #$00
  BNE UpdateLadderDownEntryDone

  LDA buttons1      ; player 1 - A
  AND #%00000100  ; only look at bit 0
  BEQ UpdateLadderDownEntryDone   
  LDX tileBelow
  CPX #$B2
  BEQ UpdateLadderDownEntrySetActive

  LDX tileBelow
  CPX #$B3
  BEQ UpdateLadderDownEntrySetActive

  JMP UpdateLadderDownEntryDone
UpdateLadderDownEntrySetActive:
  LDX #$01
  STX isOnLadder

UpdateLadderDownEntryDone:
  RTS
  
UpdateLadderMovement:
  LDX isOnLadder
  CPX #$01
  BNE UpdateLadderMovementDone

  LDA buttons1      ; player 1 - A
  AND #%00001000  ; only look at bit 0
  BEQ UpdateLadderUpMovementDone   
  
  
  LDX #$00
MoveSpriteUpLadderLoop:
  LDA $0200, x       ; load sprite X position
  SEC             ; make sure carry flag is set
  SBC #$01        ; A = A - 1
  STA $0200, x       ; save sprite X position
  INX
  INX
  INX
  INX
  CPX #$10
  BNE MoveSpriteUpLadderLoop

UpdateLadderUpMovementDone:

  LDA buttons1      ; player 1 - A
  AND #%00000100  ; only look at bit 0
  BEQ UpdateLadderMovementDone   
  

  LDX #$00
MoveSpriteDownLadderLoop:
  LDA $0200, x       ; load sprite X position
  CLC             ; make sure carry flag is set
  ADC #$01        ; A = A - 1
  STA $0200, x       ; save sprite X position
  INX
  INX
  INX
  INX
  CPX #$10
  BNE MoveSpriteDownLadderLoop

UpdateLadderMovementDone:
  RTS
  
UpdateLadderExitUp:
  LDX isOnLadder
  CPX #$01
  BNE UpdateLadderExitUpDone

  LDA buttons1      ; player 1 - A
  AND #%00001000  ; only look at bit 0
  BEQ UpdateLadderExitUpDone   
  LDX tileBelow
  CPX #$B0
  BNE UpdateLadderExitUpDone

  LDX #$00
  STX isOnLadder

UpdateLadderExitUpDone:
  RTS
  
UpdateLadderExitDown:
  LDX isOnLadder
  CPX #$01
  BNE UpdateLadderExitDownDone

  LDA buttons1      ; player 1 - A
  AND #%00000100  ; only look at bit 0
  BEQ UpdateLadderExitDownDone   
  LDX tileBelow
  CPX #$B1
  BNE UpdateLadderExitDownDone

  LDX #$00
  STX isOnLadder

UpdateLadderExitDownDone:
  RTS
  
  
UpdateLadderExitSide:
  LDX isOnLadder
  CPX #$01
  BNE UpdateLadderExitSideDone

  LDA buttons1      ; player 1 - A
  AND #%00000001  ; only look at bit 0
  BNE UpdateLadderExitSideActive  
  
  LDA buttons1      ; player 1 - A
  AND #%00000010  ; only look at bit 0
  BNE UpdateLadderExitSideActive  

  JMP UpdateLadderExitSideDone
UpdateLadderExitSideActive:  
  LDX tileBehind
  CPX #$B2
  BEQ UpdateLadderExitSideDone
  CPX #$B3
  BEQ UpdateLadderExitSideDone

  LDX #$00
  STX isOnLadder

UpdateLadderExitSideDone:
  RTS
  
UpdateLadder:
  LDX isPlayerDead
  CPX #$01
  BEQ UpdateLadderDone
  
  JSR UpdateLadderUpEntry
  JSR UpdateLadderDownEntry
  JSR UpdateLadderMovement
  JSR UpdateLadderExitUp
  JSR UpdateLadderExitDown
  JSR UpdateLadderExitSide
  
UpdateLadderDone:
  RTS