; 
; 0 REM "Apple II Kaleidoscope EhBasic NormalLuser Edit"
; 1 CLS
; 2 z=63:ws=3:we=50:t=30:o=1:n=0:p=3:d=12
; 3 FORW=wsTOwe:IW=0:FORI=oTOt:IW=IW+W:X=IW/12+r:I40=z-I:FORJ=nTOt:K=I+J
; 4 K40=z-K:PENJ*p/(I+p)+X:PLOTI,K:PLOTK,I:PLOTI40,K40:PLOTK40,I40
; 5 PLOTK,I40:PLOTI40,K:PLOTI,K40:PLOTK40,I:NEXTJ,I:r=r+7:IFr>64THENr=0
; 6 NEXTW
; 7 GOTO 3


; ASM version from:
;https://llx.com/Neil/a2/kal2.html
START    =     $1D00 ;$400

A1L      =     $E3
A1H      =     $E4
K40      =     $E5
I40      =     $E6
IWL      =     $E7
IWH      =     $E8
I        =     $E9
W        =     $EA
J        =     $DD ; CAN'T USE EHBASIC BEEP
K        =     $DE ; CAN'T USE EHBASIC BEEP

VGAClock          = $E2       ; IF NMI hooked up to vsync this will DEC.
;PlotColor         = $EC       ; Color for plot function 
Screen            = $20       ; GFX screen location
ScreenH           = $21       ; to draw TO


    .ORG   START
        jsr CLS
        LDA   #3         ;FOR W=3 TO 50
        STA   W
WLP:      
        LDA   #0         ;IW=0
        STA   IWL
        STA   IWH
        LDA   #63        ;I40=40 ;Size
        STA   I40
        LDA   #1         ;FOR I=1 TO 19
        STA   I
ILP:      
        LDA   W          ;IW=IW+W
        CLC
        ADC   IWL
        STA   IWL
        BCC   ILP1
        INC   IWH
ILP1:     
        STA   A1L        ;X=IW/12
        LDA   IWH
        STA   A1H
        LDY   #16        ;(inline 16/8 division)
        LDA   #0
DIV1LP:
        ASL   A1L
        ROL   A1H
        ROL
        CMP   #12
        BCC   DIV1A
        SBC   #12
        INC   A1L
DIV1A:  
        DEY
        BNE   DIV1LP
        LDX   A1L
        DEC   I40        ;I40=I40-1
        LDA   I40        ;K40=I40
        STA   K40
        LDA   #0         ;FOR J=0 TO 19
        STA   J
JLP:     
        CLC              ;K=I+J
        ADC   I
        STA   K
        ;LDA   KBD        ;IF PEEK(KBD)>127 THEN DONE
        ;BPL   NOKEY
        ;STA   KBDSTRB
        ;JMP   DONE

NOKEY:  
        LDA   J          ;COLOR=J*3/(I+3)+X
        ASL
        ADC   J
        STA   A1L
        LDA   I
        ADC   #3
        STA   A1H
        LDA   #0         ;(inline 8/8 division)
        LDY   #8
DIV2LP: 
        ASL   A1L
        ROL
        CMP   A1H
        BCC   DIV2A
        SBC   A1H
        INC   A1L
DIV2A:
        DEY
        BNE   DIV2LP
        TXA
        CLC
        ADC   A1L
        
        ;JSR   SETCOL
        TAX   ;Set Color
        LDY   I          ;PLOT I,K: etc...
        LDA   K
        JSR   PLOT
        LDY   K
        LDA   I
        JSR   PLOT
        LDY   I40
        LDA   K40
        JSR   PLOT
        LDY   K40
        LDA   I40
        JSR   PLOT
        LDY   K
        LDA   I40
        JSR   PLOT
        LDY   I40
        LDA   K
        JSR   PLOT
        LDY   I
        LDA   K40
        JSR   PLOT
        LDY   K40
        LDA   I
        JSR   PLOT
        DEC   K40        ;K40=K40-1
        INC   J          ;NEXT J
        LDA   J
        CMP   #31;#20 ;size/2
        BNE   JLP
        INC   I          ;NEXT I
        LDA   I
        CMP   #31;#20 ;size/2
        BEQ   NOILP
        
        ;LDA #1
        ;JSR Delay ;to slow it down
        
        JMP   ILP
NOILP:
        INC   W          ;NEXT W
        LDA   W
        ;CMP   #51
        ;BEQ   DONE
        JMP   WLP
DONE:
        RTS


PLOT:;Fifty1Ford/NormalLuser
      ;Maybe I should add bounds checks??
      ;It is faster without
      ;TXA                     ; A IS ROW 0-63
      ;LDY Itempl              ; Y IS COLUMN 0-99
      ;LDX PlotColor           ; X IS COLOR
      ASL                     ;Double the row count. Array is entries of 2 bytes (16 bit) each. 
      PHX                     ;Put X in stack
      TAX                     ;Move doubled row count to A
      LDA HLINES,X            ;
      STA Screen
      INX
      LDA HLINES,X
      STA ScreenH
      PLX               ;PULL X FROM STACK, REPLACE WITH PLA AND REMOVE BELOW?
      TXA               ;MOVE COLOR FROM X TO A
      STA (Screen),Y    ;STORE COLOR INTO LINE OFFSET BY ROW COUNT IN Y
      RTS
      
Delay:
 BEQ NoDelay  ; 0, No delay
 STA VGAClock ; Store the number of cycles we want to wait.
DelayTop:    
 LDA VGAClock ; See if the Vsync NMI has counted down to 0.
 BNE DelayTop ; Keep waiting until 0.
NoDelay:
 RTS

CLS:
      LDA #0
      BRA FillScreen
COLOR: 

FillScreen:
 STZ Screen ; Ben Eater's Worlds Worst Video card 
 LDY #$20   ; uses the upper 8Kb of system RAM
 STY ScreenH; This starts at location $2000
 LDY #0 
.MemLoop
 STA (Screen),Y
 INY
 BNE .MemLoop
 INC ScreenH
 LDX ScreenH
 CPX #$40 ;Top of screen memory is $3F-FF, 
 BNE .MemLoop; Do until $40-00
 STZ Screen ; Ben Eater's Worlds Worst Video card 
 LDA #$20   ; uses the upper 8Kb of system RAM
 STA ScreenH; This starts at location $2000
 RTS

 .org START +$200
HLINES: ;These are the line start locations for the VGA frame buffer, Adjusted to the right for better centering.
    .WORD $200F,$208F,$210F,$218F,$220F,$228F,$230F,$238F,$240F,$248F,$250F,$258F,$260F,$268F,$270F,$278F
    .WORD $280F,$288F,$290F,$298F,$2A0F,$2A8F,$2B0F,$2B8F,$2C0F,$2C8F,$2D0F,$2D8F,$2E0F,$2E8F,$2F0F,$2F8F
    .WORD $300F,$308F,$310F,$318F,$320F,$328F,$330F,$338F,$340F,$348F,$350F,$358F,$360F,$368F,$370F,$378F
    .WORD $380F,$388F,$390F,$398F,$3A0F,$3A8F,$3B0F,$3B8F,$3C0F,$3C8F,$3D0F,$3D8F,$3E0F,$3E8F,$3F0F,$3F8F        
; HLINES: ;These are the line start locations for the VGA frame buffer.
    ; .WORD $2000,$2080,$2100,$2180,$2200,$2280,$2300,$2380,$2400,$2480,$2500,$2580,$2600,$2680,$2700,$2780
    ; .WORD $2800,$2880,$2900,$2980,$2A00,$2A80,$2B00,$2B80,$2C00,$2C80,$2D00,$2D80,$2E00,$2E80,$2F00,$2F80
    ; .WORD $3000,$3080,$3100,$3180,$3200,$3280,$3300,$3380,$3400,$3480,$3500,$3580,$3600,$3680,$3700,$3780
    ; .WORD $3800,$3880,$3900,$3980,$3A00,$3A80,$3B00,$3B80,$3C00,$3C80,$3D00,$3D80,$3E00,$3E80,$3F00,$3F80        