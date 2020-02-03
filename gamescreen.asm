  .include "timer.asm"
  .include "jumping.asm"
  .include "movement.asm"
  .include "player.asm"

LoadPlayerSprites:
  LDX #$00              ; start at 0
LoadPlayerSpritesLoop:
  LDA sprites_player, x        ; load data from address (sprites +  x)
  STA $0200, x          ; store into RAM address ($0200 + x)
  INX                   ; X = X + 1
  CPX #$10              ; Compare X to hex $10, decimal 16
  BNE LoadPlayerSpritesLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
      
  RTS



ResetGame:
  LDA #$00
  STA currentLevelLow
  STA currentLevelHigh

  JSR ResetTimer

  LDA #$05
  STA liveAmount
  RTS

InitGameScreen:
  LDA #$00
  STA ticks

  LDA #$00
  sta whichFrame

  LDA #$01
  STA gameState

  LDA #$02
  STA currentScreen

  LDA #$00
  STA isJumping
  
  LDA #$00
  STA isPlayerDead
  
  LDA #$00
  STA isOnLadder
  
  LDA #$00
  STA isScreenDone
  
  LDA #$00
  STA playerTicks
  
  LDA #$20
  STA invincibilityTicks
  
  JSR ClearSprites
  JSR LoadGameScreenBackground
  JSR LoadPlayerSprites
  JSR InitGameUI
  JSR InitEnemies
  JSR InitSpaceShips
  JSR InitTimer
  
  RTS
 
LoseLive:
  LDX liveAmount
  DEX
  STX liveAmount
  
  RTS
 
UpdateGameScreenDyingOver:
  LDX isPlayerDead
  CPX #$01
  BNE UpdateGameScreenDyingOverDone
  
  LDX isScreenDone
  CPX #$01
  BNE UpdateGameScreenDyingOverDone

  LDA timerLow
  CMP #$00
  BNE UpdateGameScreenDyingOverToLoseLive
  
  LDA timerHigh
  CMP #$00
  BNE UpdateGameScreenDyingOverToLoseLive

  LDA #$06
  STA timerHigh

UpdateGameScreenDyingOverToLoseLive:
  JSR LoseLive
  LDA liveAmount
  CMP #$00
  BEQ UpdateGameScreenDyingOverToGameOver
  JSR InitWinningScreen
  JMP UpdateGameScreenDyingOverDone
UpdateGameScreenDyingOverToGameOver:
  JSR InitGameOverScreen

UpdateGameScreenDyingOverDone:
  RTS
  
UpdateGameScreenInvincibility:
  LDX invincibilityTicks
  CPX #$00
  BEQ UpdateGameScreenInvincibilityDone

  DEX
  STX invincibilityTicks

UpdateGameScreenInvincibilityDone:  
  RTS  

UpdateGameScreen:

  JSR LatchController
  JSR ReadController1
  JSR ReadController2
  JSR GatherPlayerPosition
  JSR TileGather
  JSR TileGather2
  JSR Movement
  JSR Jumping
  JSR FallingCheck
  JSR UpdateLadder
  JSR PlayerDying
  JSR UpdatePlayerSprites
  JSR UpdateEnemies
  JSR UpdateSpaceships
  JSR UpdateGameScreenDyingOver
  JSR UpdateTimer
  JSR UpdateGameScreenInvincibility
  JSR PPUCleanUp
  
  RTS
  RTS