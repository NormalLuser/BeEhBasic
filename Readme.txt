BeEhBasic.

EhBasic for your BenEater computer.

NOW WITH GFX COMMANDS!

This version of EhBasic has been modified to include some graphics commands for the Ben Eater 6502 + Worlds Worst Video Card kit.

Remember, all commands must be in CAPS

New non-standard commands:

CLS 		-Clears screen to black
COLOR X	-Colors screen chosen color IE COLOR 48 
PLOT X,Y	-Plots a pixel with x/y coordinate system.

Currently to change the plot color you would POKE the value to $EC. 
POKE $EC, 3


Example BASIC code
RANDOM WITH PLOT

1 R=PI
2 CLS
11 R = RND(R)
12 Z=Z+1
11 R = RND(R)
14 X=R*100
29 R = RND(R)
30 R = RND(R)
31 Y=R*64
49 R = RND(R)
50 R = RND(R)
60 C=1+R*62
70 PRINT X,Y,C
80 POKE $EC,C
81 PLOT X,Y
91 R=R*TWOPI+Z
92 IF Z > 100 THEN R = R+Z*0.6180339
93 IF Z > 201 THEN Z = 0
100 GOTO 11




Colors

1 COLOR X
2 ? "Color ",X
3 ? "--RRGGBB"
4 ? BIN$(X,8)
5 X=X+1
6 IF X>63THEN X = 0
7 FOR Y = 1 TO 500
8 REM "PAUSE"
9 NEXT Y
10 GOTO 1


Shapes

61 ? "CLEAR SCREEN"
62 B= 0
70 COLOR B

109 ? "DRAW H LINE WITH POKE"
110 FOR X = 0 TO 15
120  POKE (8455+X),255
130 NEXT

131 ? "DRAW SQUARES"
134 Y = 9482
135 Z = 4
136 GOSUB 2139

137 Y = 10428
138 Z = 60
139 GOSUB 2139

209 ? "DRAW H LINE WITH POKE"
210 FOR X = 0 TO 15
220  POKE (13362+X),90
230 NEXT

339 ? "DRAW V LINE WITH POKE"
340 FOR X = 0 TO 7
350 POKE (11520+30+(X*128)),48
360 NEXT

399 ? "DRAW D LINE WITH POKE"
400 Y=1
410 FOR X = 2 TO 57
420 POKE (8476+Y),X
421 POKE (8477+Y),X
422 Y=Y+129
430 NEXT

499 ? "DRAW -D LINE WITH POKE"
500 Y=1
510 FOR X = 2 TO 56
520 POKE (15872-Y),X
521 POKE (15873-Y),X
522 Y=Y+126
530 NEXT

599 ? "END PROGRAM"
600 GOTO 9060

2139 ? "DRAW SQUARE"
2140 FOR X = 0 TO 7
2150 POKE (Y+X),Z
2151 POKE (Y+128+X),Z
2152 POKE (Y+256+X),Z
2153 POKE (Y+384+X),Z
2154 POKE (Y+512+X),Z
2155 POKE (Y+640+X),Z
2156 POKE (Y+768+X),Z
2157 POKE (Y+896+X),Z
2160 NEXT
2170 RETURN

9060 ? "It Ran!"
9061 B=B+1
9062 IF B > 255 THEN GOTO 9070
9063 ? "Color ",B
9064 ? "--RRGGBB"
9065 ? BIN$(B,8)
9069 GOTO 70
9070 GOTO 61

