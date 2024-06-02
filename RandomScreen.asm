;NormalLuser Random Screen fill for the Ben Eater Worlds Worst Video Card+6502
;This is a 6502 ASM version of this code:
;NormalLuser Basic program to Clear Screen and then Random Fill:
;Ben Eater MS Basic version :
;1 FOR R = 8192 TO 16381
;2 POKE R,0
;3 NEXT R
;10 B=RND(1)*8192
;20 B=B+8192
;30 C=RND(1)*64
;40 POKE B,C
;50 GOTO 10
; BeEhBasic fast version :
;0 S=8192:E=16381:F=64:Z=0
;1 FORR=STOE:POKER,Z:NEXT
;2 DO:POKES+RND(Z)*S,RND(Z)*F:LOOP

ACIA         = $5000 ;Modified to match Ben Eater mapping was $4000 
ACIA_RX      = ACIA ;$5000
ACIA_TX      = ACIA ;$5000
ACIA_STATUS  = ACIA+1;$5001
ACIA_COMMAND = ACIA+2;$5002
ACIA_CONTROL = ACIA+3;$5003
;Added Ben Eater Mapping. 
VIA              = $6000
VIA_PORTB        = VIA
VIA_PORTA        = VIA+1;$6001
VIA_DDRB         = VIA+2;$6002
VIA_DDRA         = VIA+3;$6003
VIA_T1CL         = VIA+4;$6004 ;Can be used for rnd seed start
VIA_T1CH         = VIA+5;$6005
VIA_T1LL         = VIA+6;$6006
VIA_T1LH         = VIA+7;$6007
VIA_T2CL         = VIA+8;$6008
VIA_T2CH         = VIA+9;$6009
VIA_SHIFT        = VIA+10;$600A
VIA_AUX          = VIA+11;$600B ;Set to 0 to stop BEEP ALSO ACR
VIA_PCR          = VIA+12;$600C
VIA_IFR          = VIA+13;$600F
VIA_IER          = VIA+14;$600E
VIA_IORA         = VIA+15;$600F

Display           = $2000     ;Start of memory mapped display. 100x64 mapped to 128x64
Screen            = $ED       ; GFX screen location
ScreenH           = $EE       ; to draw TO

seed2             = $7                        
seed              = $E2;$8 ; Lets use the VGAClock location as the seed location!
                           ; That way 60 times a second one is DEC'd from the seed
                           ; Will it make it more 'random'?
                           ; Yep, works great! The seed number is 'randomly' DEC'd 
                           ; so there are 8 chances for it to change.
VGAClock          = $E2;***** IF NMI hooked up to vsync this will DEC *****


ProgramStart      = $1D00 ;$500





 .org ProgramStart

 LDA #7 ;VGAClock;If no VGA clock use a number, 7 works
 STA seed
 LDA #77
 ;ORA VGAClock; If no VGA clock use a number, 77 works 
 sta seed2
 jsr FillScreen ;clear screen
 
 .org ProgramStart+$10
NewSeed:
 ;JSR GetRND
Top:
 ;lda VGAClock
 ;BNE NewSeed
 ;JSR GetRND
 ;sta PixelPointer
 ;JSR GetRND ;Unroll now that I'm down to one RND call
GetRND: ;Routine from:
; https://github.com/bbbradsmith/prng_6502/tree/master
; Random number generators for 6502 / NES.
;
; overlapped version, computes all 8 iterations in an overlapping fashion
; 69 cycles for RND; 35 bytes
; 76 cycles a pixel drawn*, 18,421 pixels a second, 307 pixels a frame at 60fps VGA
;
; * If Vsync is connected to the NMI, and a DEC is done in the NMI routine
; on the same zp location as the seed value that adds a few cycles 60 times a second.
; so 76.04 cycles a pixel or something like that if you assume 15 cycles for the NMI.
; This adds to the 'randomness' and the NMI routine already exists on my ROM. Win/Win.
; The JMP for the loop takes 6 cycles, or 110,526 a second. 
;If I unroll 4 times that means I save:
; 82,895 cycles, using just 27,631 cycles a second on the jmp.
; 1,085 more pixels a second for a toatl of 19,506 pixels a second.
; 
galois16o: ;I get 63 cycles for the RND routine .Seems to work well.

 	lda seed2
	tay ; store copy of high byte
	; compute seed+1 ($39>>1 = %11100)
	lsr ; shift to consume zeroes on left...
	lsr
	lsr
	sta seed2 ; now recreate the remaining bits in reverse order... %111
	lsr
	eor seed2
	lsr
	eor seed2
	eor seed ; recombine with original low byte
	sta seed2
	; compute seed+0 ($39 = %111001)
	tya ; original high byte
	sta seed
	asl
	eor seed
	asl
	eor seed
	asl
	asl
	asl
	eor seed
	sta seed
	

    LDY seed2;PixelPointer ;Speed up more by using other byte?
    STA (Screen),y; Go ahead and draw off screen for now.
    ;jsr GetRND   ; Skip this for speed, use last color for row lookup instead
    ;tax          ; I could just INX and allow my 'random' lookup array take care of it
    ;lda Array1,x ; But this adds extra 'random' without any extra cycles?
    ;               The math to do 'between $20 and $3F' is more I'd think?
    ora #$20      ; Nope! Only 4 cycles vrs 6 to do the ORA and AND. Is it as 'random' though?
    and #$3F      ; Seems 'random' enough to me. And it is fast! 
    sta ScreenH  
 	
 jmp Top

 .org ProgramStart+$50 ;Random noise version
nTop:
 
 	lda seed2
	tay ; store copy of high byte
	; compute seed+1 ($39>>1 = %11100)
	lsr ; shift to consume zeroes on left...
	lsr
	lsr
	sta seed2 ; now recreate the remaining bits in reverse order... %111
	lsr
	eor seed2
	lsr
	eor seed2
	eor seed ; recombine with original low byte
	sta seed2
	; compute seed+0 ($39 = %111001)
	tya ; original high byte
	sta seed
	asl
	eor seed
	asl
	eor seed
	asl
	asl
	asl
	eor seed
	sta seed
    ;jsr LAB_BEEP

      tax 
      LDA  VIA_DDRB;$6002
      ORA  #$80    ;%1000-0000
      STA  VIA_DDRB;$6002   ; Set the high bit in DDRB, to make PB7 an output.
      
      ;WAIT, I don't think I need this LDA/ORA stuff for this register?
      ;Look into just doing a STA #$C0
      LDA  VIA_AUX;$600b
      ;Using only 1100-0000 instead of 1111-0000
      ;because it is a lower duty cycle and sounds fine.
      ;This would be a retangle wave instead of a square wave, but no real matter.
      ;This lower duty cycle is better if you have a speaker hooked 
      ;right up to the VIA to keep it from drawing too much power.
          
                            ; Set the two high bits in the ACR to get the
      ORA  #$C0   ;1100-0000; square-wave/RECTANGLE output on PB7.  (Don't enable the
      STA  VIA_AUX;$600b    ; T1 interrupt in the IER though.)

      LDA  #255           ; Set the T1 timeout period. 
                          ;LOWER THIS TO SOMETHING LIKE 77 FOR 1MHZ CPU CLOCK 
      STA  VIA_T1CL;$6004;;USE 255 if the Φ2 rate is 5MHz.  To get it going, write to
                           ;VIA_T1CH 
      TXA ;BEEP IN A
      STA VIA_T1CH;$6005;
        

    LDY seed2;PixelPointer ;Speed up more by using other byte?
    

    STA (Screen),y; Go ahead and draw off screen for now.
    ora #$20      ; Nope! Only 4 cycles vrs 6 to do the ORA and AND. Is it as 'random' though?
    and #$3F      ; Seems 'random' enough to me. And it is fast! 
    sta ScreenH  
 	
 jmp nTop
 

 .org ProgramStart+$100
FillScreen: ; Setup Screen pointer
 STZ Screen ; Ben Eater's Worlds Worst Video card 
 LDA #$20   ; uses the upper 8Kb of system RAM
 STA ScreenH; This starts at location $2000
 LDY #0     ; Zero out Y for loop, we'll clear off screen area as well.
 LDA #0     ; Always use 0 for color with this routine. Cold load a memory location instead
.MemLoop
 STA (Screen),Y
 INY
 BNE .MemLoop
 INC ScreenH
 LDX ScreenH
 CPX #$40 ;Top of screen memory is $3F-FF, 
 BNE .MemLoop;Do until $40-00
            ; Reset it all
 STZ Screen ; Ben Eater's Worlds Worst Video card 
 LDA #$20   ; uses the upper 8Kb of system RAM
 STA ScreenH; This starts at location $2000
 rts


; LAB_BEEP:;Fifty1Ford
;       ;JSR LAB_GTBY ;get byte In x  
;       ;PHA        
;       TXA ;TRANSFER X TO A
;       BEQ BEEP_Off    ;if note 0 turn off beep; 

;       LDA  VIA_DDRB;$6002
;       ORA  #$80    ;%1000-0000
;       STA  VIA_DDRB;$6002   ; Set the high bit in DDRB, to make PB7 an output.
      
;       ;WAIT, I don't think I need this LDA/ORA stuff for this register?
;       ;Look into just doing a STA #$C0
;       LDA  VIA_AUX;$600b
;       ;Using only 1100-0000 instead of 1111-0000
;       ;because it is a lower duty cycle and sounds fine.
;       ;This would be a retangle wave instead of a square wave, but no real matter.
;       ;This lower duty cycle is better if you have a speaker hooked 
;       ;right up to the VIA to keep it from drawing too much power.
          
;                             ; Set the two high bits in the ACR to get the
;       ORA  #$C0   ;1100-0000; square-wave/RECTANGLE output on PB7.  (Don't enable the
;       STA  VIA_AUX;$600b    ; T1 interrupt in the IER though.)

;       LDA  #255           ; Set the T1 timeout period. 
;                           ;LOWER THIS TO SOMETHING LIKE 77 FOR 1MHZ CPU CLOCK 
;       STA  VIA_T1CL;$6004;;USE 255 if the Φ2 rate is 5MHz.  To get it going, write to
;                            ;VIA_T1CH 
;       TXA ;BEEP IN A
;       STA VIA_T1CH;$6005;
    
;       RTS
; BEEP_Off:
;         STZ VIA_AUX;$600b;VIA_ACR <<< I THINK I ONLY NEED THIS???
;                          ;Timer is still going but nothing is output?
;         TXA
;         RTS


; Works well, but not needed:
; This is all the high bytes of the Screen pointer in random order, non repeating within each
; 32 entry line x 8  lines for 256 random but evenly distributed values $20 to $3F to match the VGA display map. 
; This seems like a fast way to take care of the upper screen byte and it introduces some randomness.
;  .org $600 ;Page align for speed
; Array1: ;https://www.calculatorsoup.com/calculators/statistics/random-number-generator.php
;  .byte 50,42,46,54,57,52,43,53,39,63,35,38,62,36,48,55,56,33,49,45,44,34,60,40,61,32,37,47,59,51,41,58
;  .byte 37,59,52,62,34,38,60,35,47,42,51,49,39,44,63,43,40,58,41,50,45,54,32,48,36,57,56,33,55,61,46,53
;  .byte 52,55,53,33,42,47,34,40,62,61,32,58,41,50,45,51,57,60,54,59,63,36,49,37,46,39,35,43,44,38,48,56
;  .byte 41,43,40,55,57,39,38,59,63,44,33,53,62,48,42,60,49,52,32,37,46,58,34,54,36,35,45,56,47,61,51,50
;  .byte 61,34,32,62,51,56,33,39,50,38,57,54,46,43,36,59,58,47,42,49,45,44,40,52,55,41,48,53,35,63,37,60
;  .byte 53,46,55,63,62,40,34,32,48,49,38,44,52,33,51,57,54,60,37,43,41,58,56,42,35,36,59,61,47,39,45,50
;  .byte 62,32,37,57,49,43,47,35,63,59,54,33,58,56,34,45,42,46,61,48,39,36,55,52,51,38,44,40,53,41,50,60
;  .byte 57,56,40,55,53,43,54,47,44,35,61,49,46,33,51,42,60,45,63,39,32,38,37,52,34,62,50,59,48,36,41,58



 ;Other routines:
; galois16: ;133 cycles
; 	ldy #8
; 	lda seed+0
; lb1:
; 	asl        ; shift the register
; 	rol seed+1
; 	bcc lb2
; 	eor #$39   ; apply XOR feedback whenever a 1 bit is shifted out
; lb2:
; 	dey
; 	bne lb1
; 	sta seed+0
; 	cmp #0     ; reload flags
; 	rts
; galois16u: ;98 clock cycles
; 	lda seed+0
; ;	.repeat 8
; 	asl
; 	rol seed+1
; 	bcc lb3
; 	EOR #$39
; lb3:	
; 	asl
; 	rol seed+1
; 	bcc lb4
; 	eor #$39
; lb4:
; 	asl
; 	rol seed+1
; 	bcc lb5
; 	eor #$39
; lb5:
; 	asl
; 	rol seed+1
; 	bcc lb6
; 	eor #$39
; lb6:
; 	asl
; 	rol seed+1
; 	bcc lb7
; 	eor #$39
; lb7:
; 	asl
; 	rol seed+1
; 	bcc lb8
; 	eor #$39
; lb8:
; 	asl
; 	rol seed+1
; 	bcc lb9
; 	eor #$39
; lb9
; 	asl
; 	rol seed+1
; 	bcc lb10
; 	eor #$39
; lb10:
  
; ; ;.endrepeat:
;  lb11:
;  	sta seed+0
;  	cmp #0
;  	rts
