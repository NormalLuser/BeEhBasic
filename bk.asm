     ;.segment "BkLoad"
  ;.org $1000

vidpage           = $ED       ; unused
image             = $FB

 PHP
 LDX #32 ;32 'lines' as each line is 255 IE 2 lines each
 ;set our source memory address to copy from
 ;change to $AD00 ;$ADD0
 ;lda #$D0 
 lda #$00 
 sta image + 1 ;$FB
 lda #$AD
 sta image  ; $FC

 lda #$00 ;set our destination memory to copy to, $2000, WRAM
 sta vidpage +1 ;$FD
 lda #$20
 sta vidpage ;$FE
 ldy #$00 ;reset x and y for our loop
 ;ldx #$00
LoopI: ;Image loop
 lda ($FB),Y ;indirect index source memory address, starting at $00
 sta ($FD),Y ;indirect index dest memory address, starting at $00
 INY
 bne LoopI ;loop until our dest goes over 255
 inc $FC ;increment high order source memory address, starting at $80
 inc $FE ;increment high order dest memory address, starting at $60
 lda $FE ;load high order mem address into a
 ;copy 68 lines
 DEX
 bne LoopI ;if we're not there yet, loop
 NOP
 PLP
 RTS
 
