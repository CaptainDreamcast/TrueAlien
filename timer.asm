;timerLow .rs 1
;timerHigh .rs 1
;timerTicks .rs 1

ResetTimer:
  LDA #$00
  STA timerLow

  LDA #$06
  STA timerHigh

  RTS

; 310

TIMERTEXTX       = $10
TIMERTEXTY       = $20

; DD D2 D6 CE E4 C0 C0
TimerText:
  .db $DD,$D2,$D6,$CE,$E4,$C0,$C0
TimerTextEnd

InitTimerDisplay:
  LDX #$00
  LDY #$00

  LDA #TIMERTEXTX
  STA temp1

  LDA #TIMERTEXTY
  STA temp2
  
InitTimerDisplayLoop:

  LDA temp2
  STA $2D0, x          ; store into RAM address ($0200 + x)
  LDA TimerText, y
  STA $2D1, x          ; store into RAM address ($0200 + x)
  LDA #$00
  STA $2D2, x          ; store into RAM address ($0200 + x)
  LDA temp1
  STA $2D3, x          ; store into RAM address ($0200 + x)
  CLC
  ADC #$08
  STA temp1
  INX
  INX
  INX
  INX
  INY 

  CPY #(TimerTextEnd - TimerText)  ; Compare X to hex $10, decimal 16
  BNE InitTimerDisplayLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
                        ; if compare was equal to 16, keep going dow
						

  
  RTS

InitTimer8:
  LDA timerLow
  STA arg1
  LDA timerHigh
  STA arg2
  LDA #$0A
  STA arg3
  JSR IncreaseTimerAmount
  LDA out1
  STA timerLow
  LDA out2
  STA timerHigh
  RTS

InitTimer:
  LDA #$00
  STA timerTicks
  
  JSR InitTimerDisplay
  JSR UpdateTimerDisplay
  
  RTS
  
  
UpdateTimerDisplay:
  LDA timerHigh
  CLC
  ADC #$C0
  LDY #$05
  STA $2D1 + (4 * 5)
  
  LDA timerLow
  CLC
  ADC #$C0
  STA $2D1 + (4 * 6)

  RTS
 
UpdateTimerOverCheck:
  LDX timerLow
  CPX #$00
  BNE UpdateTimerOverCheckOver
  
  LDX timerHigh
  CPX #$00
  BNE UpdateTimerOverCheckOver

  LDA #$01
  STA isPlayerDead
  
UpdateTimerOverCheckOver:
  RTS 
  
UpdateTimer:
  LDX timerTicks
  INX
  STX timerTicks
  CPX #$20
  BNE UpdateTimerDone
  
  LDX #$00
  STX timerTicks
  
  LDA timerLow
  STA arg1
  LDA timerHigh
  STA arg2
  JSR DecreaseTimer
  LDA out1
  STA timerLow
  LDA out2
  STA timerHigh
  JSR UpdateTimerDisplay
  
  JSR UpdateTimerOverCheck
UpdateTimerDone:
  RTS