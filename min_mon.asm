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
VIA_T1CL         = VIA+4;$6004
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

VGA_SCREENH      = $20 ;VGA Screen area starts at $2000
VGA_SCREENL      = $00


;.org $8000
; minimal monitor for EhBASIC and 6502 simulator V1.05
; tabs converted to space, tabwidth=6


; Polled 65c51 I/O routines adapted to EhBASIC. Delay routine from
; http://forum.6502.org/viewtopic.php?f=4&t=2543&start=30#p29795

      .include "basic.asm"

; put the IRQ and MNI code in RAM so that it can be changed
; Fifty1Ford.... Umm, I broke this I think...
IRQ_vec     = VEC_SV+2        ; IRQ code vector
;NMI_vec     = IRQ_vec+$0A     ; NMI code vector

; now the code. all this does is set up the vectors and interrupt code
; and wait for the user to select [C]old or [W]arm start. nothing else
; fits in less than 128 bytes

      .segment "CODE"         ; pretend this is in a 1/8K ROM

; reset vector points here

RES_vec
      CLD                     ; clear decimal mode
      LDX   #$FF              ; empty stack
      TXS                     ; set the stack
      JSR ACIAsetup

; set up vectors and interrupt code, copy them to page 2

      LDY   #END_CODE-LAB_vec ; set index/count
LAB_stlp
      LDA   LAB_vec-1,Y       ; get byte from interrupt code
      STA   VEC_IN-1,Y        ; save to RAM
      DEY                     ; decrement index/count
      BNE   LAB_stlp          ; loop if more to do

; now do the signon message, Y = $00 here

LAB_signon
      LDA   LAB_mess,Y        ; get byte from sign on message
      BEQ   LAB_nokey         ; exit loop if done

      JSR   V_OUTP            ; output character
      INY                     ; increment index
      BNE   LAB_signon        ; loop, branch always

LAB_nokey
      JSR   V_INPT            ; call scan input device
      BCC   LAB_nokey         ; loop if no key

      AND   #$DF              ; mask xx0x xxxx, ensure upper case
      CMP   #'W'              ; compare with [W]arm start
      BEQ   LAB_dowarm        ; branch if [W]arm start

      CMP   #'C'              ; compare with [C]old start
      BNE   RES_vec           ; loop if not [C]old start

      JMP   LAB_COLD          ; do EhBASIC cold start

LAB_dowarm
      JMP   LAB_WARM          ; do EhBASIC warm start





ACIAsetup
      LDA #$00                ; write anything to status register for program reset
      STA ACIA_STATUS
      LDA #$0B                ; %0000 1011 = Receiver odd parity check
                              ;              Parity mode disabled
                              ;              Receiver normal mode
                              ;              RTSB Low, trans int disabled
                              ;              IRQB disabled
                              ;              Data terminal ready (DTRB low)
      STA ACIA_COMMAND        ; set command register  
      LDA #$1F                ; %0001 1111 = 19200 Baud
                              ;              External receiver
                              ;              8 bit words
                              ;              1 stop bit
      STA ACIA_CONTROL        ; set control register  
      RTS

ACIAout
      PHA                     ; save A
      LDA ACIA_STATUS         ; Read (and ignore) ACIA status register
      PLA                     ; restore A
      STA ACIA_TX             ; write byte
      JSR ACIAdelay           ; delay because of bug
      RTS

ACIAdelay
      PHY                     ; Save Y Reg
      PHX                     ; Save X Reg
DELAY_LOOP
      LDY   #6                ; Get delay value (clock rate in MHz 2 clock cycles)
MINIDLY
      LDX   #$68              ; Seed X reg
DELAY_1
      DEX                     ; Decrement low index
      BNE   DELAY_1           ; Loop back until done
      DEY                     ; Decrease by one
      BNE   MINIDLY           ; Loop until done
      PLX                     ; Restore X Reg
      PLY                     ; Restore Y Reg
DELAY_DONE
      RTS                     ; Delay done, return

ACIAin
;Fifty1Ford Hrmmm.. Can we get keys from the keyboard?
      LDA ACIA_STATUS         ; get ACIA status
      AND #$08                ; mask rx buffer status flag
      BEQ LAB_nobyw           ; branch if no byte waiting
      LDA ACIA_RX             ; get byte from ACIA data port
      SEC                     ; flag byte received
      RTS
LAB_nobyw
      CLC                     ; flag no byte received
no_load                       ; empty load vector for EhBASIC
no_save                       ; empty save vector for EhBASIC
      RTS

; vector tables

LAB_vec
      .word ACIAin            ; byte in from simulated ACIA
      .word ACIAout           ; byte out to simulated ACIA
      .word no_load           ; null load vector for EhBASIC
      .word no_save           ; null save vector for EhBASIC

; EhBASIC IRQ support

IRQ_CODE
      PHA                     ; save A
      LDA   IrqBase           ; get the IRQ flag byte
      LSR                     ; shift the set b7 to b6, and on down ...
      ORA   IrqBase           ; OR the original back in
      STA   IrqBase           ; save the new IRQ flag byte
      PLA                     ; restore A
      RTI

; EhBASIC NMI support

NMI_CODE
      PHA                     ; save A
      ; ;FIFTY
      ;  PHP ;SAVE PROCESS FLAGS
      ;  LDA #1
      ;  ADC $E2
      ;  STA $E2
      ;  STA $2626

      LDA   NmiBase           ; get the NMI flag byte
      LSR                     ; shift the set b7 to b6, and on down ...
      ORA   NmiBase           ; OR the original back in
      STA   NmiBase           ; save the new NMI flag byte
      
      ; PLP ;FIFTY RESTORE PROCESS FLAGS

      PLA                     ; restore A
      RTI

END_CODE

NMI_vec
; NMI:;
      
      PHP ;Push that CPU flag
      DEC $E2 ;Lets dec 
      PLP ;Pull that flag!
      RTI
      
      ;Attempt at vga 'clock' and test
      ;TRY THIS ONE OUT -YEP ALL YOU NEED FOR CLOCK
        ;INC $E2 ;VGAClock
      ;  DEC $E2 ;Lets dec instead, that way we can reset to
        ;wanted count and look at the count down for 0.
        ;May use for beep/music timer
        ;OK, this can mess with the carry flag.
        ;causes random screw ups.
        ;Be sure to push and pull the processor status flags!    

        ;LDA $E2 ;SHOW BLINKIN' PIXEL
        ;STA $2626 ;FOR TEST


;       ;draw routine here.
;       ;one routine per NMI, then return.
;       ;If we add more than one NMI draw we will need to 
;       ;figure out a good way to give up some time
;       ;to basic.. or maybe just do sprites and give
;       ;basic any scraps.....?

      
      ;LDA SpriteMove
      ;BEQ NoMove
      ;JSR DrawSprite
;NoMove:

;       ;check for a clear from CLS


;       ;Check for sprite from GFX

;       ;Check for pixel from MOVE


;      PLY
;      PLX
      ;PLP ;Pull that flag!
;      PLA
      ;RTI




LAB_mess
      .byte $0D,$0A,"6502BeEhBASIC 3.1 [C]old/[W]arm?",$00
                              ; sign on string
 ; .org $FE06
;   .include "bk.asm"

 .org $ADD0
      .include "bk.asm"

; .org $ADD0
  .segment "Image"
      .incbin "C:\Projects\6502\BeEhBasic\bk.bin"
; .org $FE06
  .segment "BkLoad"
      .incbin "bkmove.bin"    
  ;

 .org $FC00
     .include "WozCall.asm"
 
 .org $fffa
      .segment "VECTORS"

      .word NMI_vec           ; NMI vector
      ;.word NMI           ; NMI vector
      .word RES_vec           ; RESET vector
      .word IRQ_vec           ; IRQ vector

      .end RES_vec            ; set start at reset vector
      


