**BeEhBasic.**
**EhBasic for your Ben Eater 6502 Breadboard Computer.**

**Update!**
** Now with Transparent Sprite command GFXT

![Sprites](https://raw.githubusercontent.com/Fifty1Ford/BeEhBasic/main/TransparentSprites.jpg) 


Here is a little demo of what it can do:

0 C=RND(0)*63:POKE$EB,C:R=0:COLOR C

1 ?"7 Transparent Sprites":X=1:Y=1:DX=1:DY=1:R=0:S=0

2 DO:DOKE$E5,$AE00:GFXTX,Y:GFXTX+18,30-Y:DOKE$E5,$AE11

3 GFXT59-X,46-Y:GFXT59-X,Y:DOKE$E5,$AE51:GFXTX,42

4 DOKE$E5,$B700:GFXT84,Y/2+35:GFXT84,16-Y/2:Y=Y+DY:X=X+DX

5 IFX<=1ORX>=50THENDX=-DX:INCR

6 IFY<=0ORY>=16THENDY=-DY

7 IFR=2THENR=0:C=RND(0)*63:POKE$EB,C:COLOR C

8 LOOP


**NOW WITH GFX COMMANDS!**

There is now a command called GFX that will plot a 42x42 image to the screen.
This can be used like a sprite.

![Sprites](https://raw.githubusercontent.com/Fifty1Ford/BeEhBasic/main/BallSprites.jpg)

<br>
<br>
<br>

This version of EhBasic has been modified to include some graphics commands for the Ben Eater 6502 + Worlds Worst Video Card kit.
Remember, all commands must be in CAPS
New non-standard commands:

CLS 		-Clears screen to black<br>
COLOR X	 -Colors screen chosen color IE COLOR 48<br>
PLOT X,Y	-Plots a pixel with x/y coordinate system.<br>
Currently to change the plot color you would POKE the value to $EC.<br>
<br>
POKE $EC, 3
<br>
You can use the below one line format example to set the color and plot the pixel

**10 POKE $EC,3 : PLOT 1,1**

NOTE:
There is no bounds checking on the PLOT command. Using X values other than 0-99 and Y other than 0-63 will lead to strange and unwanted results.

**GFX X,Y -** Plots a 42x42 image into the screen. 

There is no bounds checking on the PLOT command. Using X values other than 0-99 and Y other than 0-22 will lead to strange and unwanted results.
Currently to change the image copied you would POKE the value to $E5 and $E6. It must have a $00 low byte starting location, IE $AF00. It must be 128 byte aligned in the file, IE a new row every 128 bytes like the Ben Eater images. Going $AF00, then $AF80 for the next line, etc.
You can use the below example to show a spinning ball with the included files. It updates with pokes the address for the image to copy.
<br>
**1 S=0:DIM D(20):COLOR 63**
<br>
**2 DATA 175,1,175,43,175,85,198,1,198,43,198,85**
<br>
**3 FOR X=0 TO 11:READ D(X):NEXT X**
<br>
**4 DO:POKE$E6,D(S):INCS:POKE$E5,D(S):INCS:GFX30,10**
<br>
**6 IFS>11THENS=0**
<br>
**7 LOOP**
<br>

See this for a more impressive demo of the GFX command:
[FullSpin.bas](https://github.com/Fifty1Ford/BeEhBasic/blob/main/FullSpin.bas)

**NOTE:**
The Graphics commands use a lot of cycles. I highly recommend running your 6502 at 5Mhz with the VGA kit.
If you use the VGA kit, disconnect your 6502 clock wire from the 1Mhz crystal and use a jumper wire to connect your 6502 to the first counter of the VGA setup. IE a 5mhz clock. You may need to add additional bypass capacitors to your power rails and run additional wires directly to power and ground rails on the breadboards to make it stable, but the stock parts should work fine at 5mhz. 

Since the Ben Eater VGA setup halts the CPU while drawing you only get to process 26% of the time if you run during Hsync or 8% of the time if you don't.
This is pretty bad with a 1mhz CPU for doing graphics.
0.26Mhz or 0.08Mhz effective speed..
Pretty bad!
But with a 5mhz clock speed you get a whole 1.3mhz or 0.4mhz effective!
That is pretty usable actually!
The 5mhz speed also makes the left side noise shrink down to one single lost pixel on the left side. This makes running during Hsync viable.

Previous Update:
Ben Eater has come out with a ACIA serial kit for the 6502!
If you don't have a ACIA chip and such laying around go ahead and get it!
https://eater.net/shop
It's got what you need and the price of the kit is less than the parts individually since you'd have to buy multi-packs of the passives.
My current hardware setup works for both address $4000 and $5000.
I should look to see what the exact difference is between my decoding and Ben’s.
But I now will use address $5000 for the ACIA to insure this software works with anyone with Ben’s Serial kit or who otherwise follows along with Ben’s videos.

<br>
