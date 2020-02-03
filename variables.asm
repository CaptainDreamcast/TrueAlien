;;;;;;;;;;;;;;;

  .rsset $0000  ;;start variables at ram location 0

VariableLocation:  
gamestate  .rs 1  ; .rs 1 means reserve one byte of space
ballx      .rs 1  ; ball horizontal position
bally      .rs 1  ; ball vertical position
ballup     .rs 1  ; 1 = ball moving up
balldown   .rs 1  ; 1 = ball moving down
ballleft   .rs 1  ; 1 = ball moving left
ballright  .rs 1  ; 1 = ball moving right
ballspeedx .rs 1  ; ball horizontal speed per frame
ballspeedy .rs 1  ; ball vertical speed per frame
paddle1ytop   .rs 1  ; player 1 paddle top vertical position
paddle2ybot   .rs 1  ; player 2 paddle bottom vertical position
buttons1   .rs 1  ; player 1 gamepad buttons, one bit per button
buttons2   .rs 1  ; player 2 gamepad buttons, one bit per button
score1     .rs 1  ; player 1 score, 0-15
score2     .rs 1  ; player 2 score, 0-15
pointerLow     .rs 1 
pointerHigh     .rs 1  
pointerLow2     .rs 1 
pointerHigh2     .rs 1  
counterLow     .rs 1 
counterHigh     .rs 1  
ticks     .rs 1  
whichFrame      .rs 1  
gameState      .rs 1
currentScreen      .rs 1 ; 0 = title, 1  = level / winning; 2 = 
isJumping .rs 1
jumpingTicks .rs 1
isGoingDown .rs 1
velocityY .rs 1
tileBelow .rs 1
tileBehind .rs 1
isOnLadder .rs 1
currentLevelLow .rs 1
currentLevelHigh .rs 1
liveAmount .rs 1
randomValue .rs 1
playerTicks .rs 1

playerX .rs 1
playerY .rs 1

isPlayerDead .rs 1
isScreenDone .rs 1

enemyAmount .rs 1

enemyX .rs 10
enemyY .rs 10
enemyGoingLeft .rs 10
enemyTicks .rs 10
enemyLeftX .rs 10
enemyRightX .rs 10

spaceShipAmount .rs 1
spaceShipsCollected .rs 1
spaceShipsCollectedInv .rs 1

spaceShipX .rs 10
spaceShipY .rs 10
spaceShipCollected .rs 10


timerLow .rs 1
timerHigh .rs 1
timerTicks .rs 1

winningTicks .rs 1

invincibilityTicks .rs 1

temp1 .rs 1
temp2 .rs 1
temp3 .rs 1
temp4 .rs 1
temp5 .rs 1

arg1 .rs 1
arg2 .rs 1
arg3 .rs 1
arg4 .rs 1
arg5 .rs 1

out1 .rs 1
out2 .rs 1
out3 .rs 1
out4 .rs 1
out5 .rs 1

BgBufferLocation:
bgBuffer .rs ($20 * 30)
bgBufferEnd .rs 1




