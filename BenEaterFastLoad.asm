; NormalLuser Ben Eater Fast Load
; Future Wozmon intergration planned for 'L' Load command.
ACIA        = $4000 
ACIA_CTRL   = ACIA+3
ACIA_CMD    = ACIA+2
ACIA_SR     = ACIA+1
ACIA_DAT    = ACIA
;'From' in Woz
STL         = $50;$26
STH         = $51;$27
YSAV        = $52;Not in Woz
FROML       = $53
FROMH       = $54
;'To' in Woz
L           = $60;$28
H           = $61;$29
TOL         = $62
TOH         = $63

MSGL        = $72
MSGH        = $73



 .org $500 
    ;LDA #$1A        ; 8-N-1, 2400 baud
    ;LDA #$1C        ; 8-N-1, 4800 baud
    ;LDA #$1E        ; 8-N-1, 9600 baud
    ;LDA #$1F        ; 8-N-1, 19200 baud
     SEI             ; Turn off IRQ's, don't want/need.
     LDA #$1F        ;* Init ACIA to 19200 Baud.
     STA ACIA_CTRL
     LDA #$0B        ;* No Parity. No IRQ
     STA ACIA_CMD
LOADBINARY
; NormalLuser Binary load
; Load an program in Binary Format.
            LDA #<MSG1
            LDX #>MSG1
            JSR SHWMSG      ;Hello Message.
            JSR NewLine
            LDA #<MSG2
            LDX #>MSG2
            JSR SHWMSG      ;Ask for Start Address.
            JSR NewLine
            LDA #'$'
            JSR ECHO       
        
            JSR GETHEX      ; Store the Storage address
            STA FROMH ;STH              
            JSR GETHEX
            STZ FROML ;STL ; Zero here because low byte in Y
            STA YSAV;TAY ;Y +  start address 0
        
            LDA #<MSG3
            LDX #>MSG3
            JSR SHWMSG      ;Ask for End Address.
            jsr NewLine
            LDA #'$'
            JSR ECHO   

            JSR GETHEX
            STA TOH ;H
            JSR GETHEX
            STA TOL ;L
            
            LDA #<MSG4
            LDX #>MSG4
            JSR SHWMSG      ;Ask for Data
            JSR NewLine
LOOPMEMORY:
            LDA FROMH
            STA STH 
            STZ STL  
            LDY YSAV        ; Low byte in Y 
            LDA TOH
            STA H
            LDA TOL 
            STA L

BINARY_LOOP ;Could  copy GETCHAR here to save cycles.
            JSR GETCHAR     ; Grab Byte from ACIA
            STA (STL),Y     ; Store it at our memory location
            ;Comment out everything down to the to INY if you don't want status
            ;IF YOU WANT JUST STATUS:
            ;LDA #'X' 
            ;STA ACIA_DAT ;DON'T CARE IF IT GETS DROPPED JUST SEND
            ;JSR PRHEX ;Too slow for AWDC ACIA
            ;This translates to HEX for a nice ASCII output
;PRHEX      ;Move inline and just send       
            AND #$0F        ;Mask LSD for hex print.
            ORA #$B0        ;Add "0".
            CMP #$BA        ;Digit?
            BCC HECHO        ;Yes, output it.
            ADC #$06        ;Add offset for letter.
HECHO    
            AND #$7F               ;*Change to "standard ASCII"
            STA     ACIA_DAT       ; Output character.
            ;Check memory pointer for max and INC
            LDX STH         ; Load our high byte
            CPX H           ; Does it match our max?
            BNE NO_HMATCH   ; Nope, just normal inc
            CPY L           ; Does the low byte match our max?
            BNE NO_HMATCH   ; Nope, just normal inc
            JMP BINARY_DONE ; MATCH! We are done!
NO_HMATCH
            INY ;Inc low byte
            BNE BINARY_LOOP ;jump if not a roll-over
            INC STH ;Roll-over. Inc the high byte.
            JMP BINARY_LOOP
 
BINARY_DONE ; Data transfer Done
            JSR NewLine     ;New line.
            LDA #<MSG5
            LDX #>MSG5
            JSR SHWMSG      ;Show Finished msg

BINARYEXTRA ; Care about garbage data at end?
            ; *For Streaming Test,jmp back to top 
            ;JMP LOOPMEMORY
            ;Could RTS here, but we could overwrite data.
            JSR GETCHAR
            LDA #'X'
            JSR ECHO
            JMP BINARYEXTRA
            ;RTS
	
;From Woz
GETHEX      ;LDA IN,Y        ; Get first char.
            JSR GETCHAR
            JSR ECHO
            EOR #$30
            CMP #$0A
            BCC DONEFIRST
            ADC #$08
DONEFIRST   ASL
            ASL
            ASL
            ASL
            STA L
            INY
            ;LDA IN,Y        ; Get next char.
            JSR GETCHAR
            JSR ECHO
            EOR #$30
            CMP #$0A
            BCC DONESECOND
            ADC #$08
DONESECOND  AND #$0F
            ORA L
            INY
            RTS


GETCHAR    
.NEXTBYTE:
            LDA ACIA_SR     ;*See if we got an incoming byte
            AND #$08        ;*Test bit 3
            BEQ .NEXTBYTE   ;*Wait for byte
            LDA ACIA_DAT    ;*Load byte
            RTS

; Moved this because we can't check WDC ACIA. IE it is too slow to use the normal ECHO
; PRHEX       AND #$0F        ;Mask LSD for hex print.
;             ORA #$B0        ;Add "0".
;             CMP #$BA        ;Digit?
;             BCC ECHO        ;Yes, output it.
;             ADC #$06        ;Add offset for letter.
; WDC ACIA ECHO Wait loop due to transmit bug
ECHO:
                PHA                    ; Save A.
                PHY
                AND #$7F               ;*Change to "standard ASCII"
                STA     ACIA_DAT       ; Output character.
                LDA     #$FF           ; Initialize delay loop.
                LDY     #$02           ; Extra Delay just in case
TXDELAY:        DEC                    ; Decrement A.
                BNE     TXDELAY        ; Until A gets to 0.
                DEY
                BNE     TXDELAY        ; Extra Delay time
                PLY
                PLA                    ; Restore A.
                RTS                    ; Return.
; Rockwell/non bugged ACIA routine,
; ECHO        PHA             ;*Save A
; .WAIT       LDA ACIA_SR     ;*Load status register for ACIA, onlye for non WDC ACIA
;             AND #$10        ;*Mask bit 4.
;             BEQ    .WAIT    ;*ACIA not done from last send, wait.
;             PLA             ;*Last send done. Restore A
;             PHA             ;*Save A again
;             AND #$7F        ;*Change to "standard ASCII"
;             STA ACIA_DAT    ;*Send it.
;             PLA             ;*Restore A again
;             RTS             ;*Done, over and out...

; This version of SHWMSG modified. Need to change for Wozmon.
SHWMSG      ;Changed msg routine to save some bytes
            ;LDA #<MSG2
            STA MSGL
            ;LDX #>MSG2
            STX MSGH
            ;PHA ;I only msg when A and Y are unused.
            ;PHY
            jsr NewLine
            LDY #$0
.PRINT      LDA (MSGL),Y
            BEQ .DONE
            JSR ECHO
            INY 
            BNE .PRINT
.DONE       ;PLY
            ;PLA
            RTS 

NewLine
 PHA
 LDA #$0D
 JSR ECHO        ;* New line.
 LDA #$0A
 JSR ECHO
 PLA
 RTS

MSG1        .byte " -NormalLuser Fast File Load- ",0
MSG2        .byte " Binary Start Address in Hex: ",0
MSG3        .byte " Binary -End- Address in Hex: ",0
MSG4        .byte " -Start Binary File Transfer- ",0
MSG5        .byte " All Bytes Imported   -Reset- ",0
; Want to save some bytes on the messages?
; MSG1        .byte "Load",0
; MSG2        .byte "Start:",0
; MSG3        .byte "End:",0
; MSG4        .byte "File",0
; MSG5        .byte "Done",0
