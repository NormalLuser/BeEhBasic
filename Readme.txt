BeEhBasic.

EhBasic for your BenEater computer.

NOW WITH GFX COMMANDS!

UPDATE!
Ben Eater has come out with a ACIA serial kit for the 6502!
If you don't have a ACIA chip and such laying around go ahead and get it!
https://eater.net/shop
It's got what you need and the price of the kit is less than the parts individually since you'd have to buy multi-packs of the passives.

My current hardware setup works for both address $4000 and $5000.
I should look to see what the exact difference is between my decoding and Ben’s. 
But I now will use address $5000 for the ACIA to insure this software works with anyone with Ben’s Serial kit or who otherwise follows along with Ben’s videos.

This version of EhBasic has been modified to include some graphics commands for the Ben Eater 6502 + Worlds Worst Video Card kit.

Remember, all commands must be in CAPS

New non-standard commands:

CLS 		-Clears screen to black
COLOR X	  -Colors screen chosen color IE COLOR 48 
PLOT X,Y	-Plots a pixel with x/y coordinate system.

Currently to change the plot color you would POKE the value to $EC. 
POKE $EC, 3
You can use the below one line format example to set the color and plot the pixel 

10 POKE $EC,3 : PLOT 1,1


Example BASIC code



BOUNCE!
Adapted from: 
https://codegolf.stackexchange.com/questions/110410/8-bit-style-bouncing-ball-around-a-canvas


1 CLS
2 PRINT "{CTRL/C} EXIT PROGRAM"
3 X = 1 : Y = 1
4 DX = 1 : DY = 1
5 POKE $EC,48 : PLOT  X,Y
6 FOR T = 1 TO 10 : NEXT
7 POKE $EC,0 : PLOT X,Y
8 X = X + DX
9 IF X <= 0 OR X >= 99 THEN DX = -DX
10 Y = Y + DY
11 IF Y <= 0 OR Y >= 63 THEN DY = -DY
12 GOTO 5




Screen Saver using plot
Modified version of above makes 'endless' patterns.
I like this one a lot.

1 CLS : C = 1
2 PRINT "{CTRL/C} EXIT PROGRAM"
3 X = 1 : Y = 1
4 DX = 1 : DY = 1
5 POKE $EC,X+C : PLOT  X,Y
6 T = T+1
7 POKE $EC,Y+C : PLOT  X,Y
8 X = X + DX
9 IF X <= 0 OR X >= 99 THEN DX = -DX
10 Y = Y + DY
11 IF Y <= 0 OR Y >= 62 THEN DY = -DY
12 IF T = 448 THEN INC X
13 IF T = 1098 THEN INC X
14 IF C > 63 THEN C = 1
15 IF T = 4400 THEN INC C : T = 0 : CLS
16 GOTO 5




RANDOM WITH PLOT
Remove line 70 to speed up.

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


Random Fill with Peek and Poke.
Good endless 'twinkle' effect with a good 'fill rate'.
I like that it uses previous pixel values as part of the RND seed.
Works well. 

1 CLS
10 R=PI
30 R=RND(R)
40 X=(R*8192)+8192
52 IF PEEK(X) = 0 THEN GOTO 90
53 C=(RND(R)*63)+1
54 IF X+C>16354 THEN X = 16300
56 POKE X+C,C
57 R=R+PEEK(X)
58 R=RND(R)
59 X=(R*8192)+8192
60 R=R*TWOPI+Z
61 INC Z
89 GOTO 52
90 R=RND(R)
91 C=(R*63)+1
95 IF X>16355 THEN X=16350
100 POKE X,C
101 IF Z>400 THEN R=R*C
102 IF Z>400 THEN Z=0
103 IF Z=100 THEN R=R*C+1.1111
104 IF Z=50 THEN R=R+C*.33331
105 IF Z > 100 THEN R=R+Z
110 GOTO 30




Colors
Cycles through the 62 colors + black
Shows the Red Green and Blue values.

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
Cycles through background colors while drawing some shapes.
This one predates the Plot command and uses peek and poke.
I did however have the COLOR command for the background color.

61 ? "CLEAR SCREEN"
62 B= 0
70 COLOR B

109 ? "DRAW H LINE WITH POKE"
110 FOR X = 0 TO 15
120 POKE (8455+X),255
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
220 POKE (13362+X),90
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

