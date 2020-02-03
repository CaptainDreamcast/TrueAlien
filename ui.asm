; 310

TOCOLLECTTEXTX       = $10
TOCOLLECTTEXTY       = $10


; 9c 91 92 99 9C A4 95 8E 8F 9D A4 80
CollectText:
  .db $DC,$D1,$D2,$D9,$DC,$E4,$D5,$CE,$CF,$DD,$E4,$C0
CollectTextEnd

InitCollectText:
  LDX #$00
  LDY #$00

  LDA #TOCOLLECTTEXTX
  STA temp1

  LDA #TOCOLLECTTEXTY
  STA temp2
  
InitCollectTextLoop:

  LDA temp2
  STA $2A0, x          ; store into RAM address ($0200 + x)
  LDA CollectText, y
  STA $2A1, x          ; store into RAM address ($0200 + x)
  LDA #$00
  STA $2A2, x          ; store into RAM address ($0200 + x)
  LDA temp1
  STA $2A3, x          ; store into RAM address ($0200 + x)
  CLC
  ADC #$08
  STA temp1
  INX
  INX
  INX
  INX
  INY
  
  CPY #$06
  BNE InitCollectLineBreakDone
  
  LDA #TOCOLLECTTEXTX
  STA temp1
  
  LDA temp2
  CLC
  ADC #$08
  STA temp2
InitCollectLineBreakDone:  

  CPY #(CollectTextEnd - CollectText)  ; Compare X to hex $10, decimal 16
  BNE InitCollectTextLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
                        ; if compare was equal to 16, keep going dow
						

  
  RTS

InitGameUI:

  JSR InitCollectText

  RTS

UpdateShipCollectionText:

  LDA spaceShipsCollectedInv
  CLC
  ADC #$C0
  STA $2A1 + (4 * 11)          ; store into RAM address ($0200 + x)
  
  RTS