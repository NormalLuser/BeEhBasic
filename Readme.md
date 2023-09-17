**BeEhBasic.**
**EhBasic for your Ben Eater 6502 Breadboard Computer.**

This is my version of EhBASIC. EhBASIC is an Enhanced version of the same kind of BASIC used in apple and C64 and other 6502 computers of the time.

A person named Lee Davison spent a lot of time working on it during his life.

For a manual and example code you can look here for a mirror of Lee's site:

http://retro.hansotten.nl/6502-sbc/lee-davison-web-site/enhanced-6502-basic/

This version is inteneded for use with the Ben Eeater 6502 computer with serial port. 
This is a breadboard computer that can be built as a kit or by following the plans.
https://eater.net/

I have been adding routines to my version of EhBASIC like PLOT and COLOR for the Worlds Worst Video Card, Beep using the VIA, and PAUSE.
The Video Card or speaker is not required to use this version of BASIC. Only the BE6502 and serial port are needed.

It is the intent that all versions work with the 'Stock' Ben Eater 6502 setup unless otherwise noted.


**Update!** 7/19/2023
![Plasma Demo](https://raw.githubusercontent.com/Fifty1Ford/BeEhBasic/main/PlasmaDemo.gif)


My version of this demo: "Plasmegg" [2002 | repack 2010 by cpcrulez]
Info found here: http://norecess.cpcscene.net/the-elders-scrollers.html

This demo uses my new BUFV command to do a V-blank sync buffer swap.
If you are using the stock system without the v-blank connedted to the NMI you should change this 
to the normal BUFF routine. You may want to add a PAUSE0 to slow down the animation a bit.

Not used in this demo but also added was a PEN routine. Now instead of POKE'ing $EC to set
the Pen color you can use the PEN command to set it.
See PlasmaDemo.bas for the basic. 
The current uploaded files should MAKE the right version of BASIC.
There is a compiled BIN file called PlasmaDemo.bin. This has the correct 
image file loaded in it. 



8/29/2023

![Double Buffer Demo](https://raw.githubusercontent.com/Fifty1Ford/BeEhBasic/main/DoubleBufferScroll.gif)

![Double Buffer Logic](https://raw.githubusercontent.com/Fifty1Ford/BeEhBasic/main/VGADoubleBufferFifty1Ford.png)





With 3 added 74 series chips, and one unused gate you already have from the VGA kit, you can have a hardware double buffer!
This takes advantage of the unused 16K of SRAM that is not mapped due to the simple address decoding of the orginal Ben Eater 6502 setup.
If you have the VGA kit with your 6502 the first thing you want to do is clock your cpu at 5Mhz. (See Note on bottom)
But the next modification you should make hardware wise is the double buffer. It makes a huge improvement in what can be done and makes draw routines easier since you get to write off screen without worrying about flickers and garbage as you draw to a live video output.

The running sprite program below uses 8 frames of animation stored in a raw bitmap on the ROM in the unused space between EhBasic and Woz Monitor .My program simply fills the screen with a random color on my new hardware screen buffer, then it draws the line using the last color used for the background color. Then I add the tick-marks,

Next I set the address in memory to copy from (one of the frames of animation) and then use the GFXA sprite routine I added to basic to draw the animation frame.

Then I use the 'BUFF' routine I added to BASIC to swap the two buffers.

I'm still amazed at how much you can do with such simple hardware and software.

This could be done without the double buffer with a self erasing sprite, but as the screens get more complex it gets harder and harder to add things without visible flickering.

I also added some BEEP commands so that there is a foot-fall sound if you have the speaker hooked up (see below).

![RUN](https://raw.githubusercontent.com/Fifty1Ford/BeEhBasic/main/RunningMan.gif)

This 10 lines of code gets me quite a lot:

0 PRINT "RUNNING MAN PROGRAM NormalLuser ART Zegley"

1 DATA 55552,55582,55614,55645,59648,59676,59710,59737,0

2 BSET1:GSET30,16:C=1:POKE$EC,0:Z=100:FORX=0TO7:READD(X):NEXTX

3 X=10:Y=2:Z=1:P=20:U=10:OX=0:R=0:S=0

4 DOKE$E5,D(S):INCS:MY=Y+31:COLOR C:MOVE0,MY:GFXH100

5 BEEP0:ZZ=Z+50:PLOTZZ,MY:PLOTZZ,MY+1:PLOTZZ,MY+2

6 PLOTZ,MY:PLOTZ,MY+1:PLOTZ,MY+2:DECZ,Z,Z,Z,Z:IFZ=0THENZ=100

7 GFXA X,Y:BUFF:INCR:IFS>7THEN S=0:BEEP200

8 IFR>58THEN10ELSEIFS=3THENBEEP200

9 MOVE0,33:GFXH 99:INCX,X:GOTO4

10 POKE$EC,C:C=RND(0)*63:R=0:Y=RND(0)*30:X=0:GOTO4



Added EhBasicRun.bin

This update adds:

BSET (1 or 0) this turns on and off hardware double buffer.

When 0 the system is in normal single framebuffer mode.
    
When 1 the VGA displays one frame buffer while the CPU controls the other.
    
BUFF This command swaps the two buffers so that the 'back buffer'
    is now the displayed buffer
     
GSET this allows you to set the sprite size without using peek and poke.






7/13/2023

Added EhBasicBeepPause.bin, BeepApple.bas, and updated basic.asm source.
This update adds a PAUSE command to ehbasic. This command does NOT use a timer.
You will need to adjust based on your clock speed. This is needed to allow BEEP 
to work correctly. 


![Speaker](https://raw.githubusercontent.com/Fifty1Ford/BeEhBasic/main/PB7Speaker.jpg) 

Connect PB7, pin 17 on the 6522 to the positive side of a 47uF electrolytic capacitor connect the - side of the capacitor to a 100Ω resistor, then to the positive speaker wire . The other speaker wire goes to ground near the 6522.

In this case I'm using a 8 Ohm 1 Watt 3 inch Adafruit speaker.

https://www.amazon.com/dp/B00XW2NPTG?psc=1&ref=ppx_yo2ov_dt_b_product_details


6/29/2023
Added BEEP command as well as first pass at a Horizontal Line routine GFXH.

BEEP 0 is off, BEEP 1 is a high tone, BEEP 255 is a low tone.

I also changed CLS so that it also stops any BEEP. 

Here is a demo:

1 DO:GETT:IFT>0THENBEEPT:POKE$EC,T:MOVET/1.5,T/2

2 LOOP

** NOTE **
BEEP is set for a 5Mhz system.
For a slower system you will need to edit the BEEP routine.
See comments in source, or just overclock to 5Mhz!!!

GFXH 5 will draw a line 5 pixels long starting at the last MOVE position.

It uses the color stored in $EC, you can use POKE $EC,48 to set the color.

Here is a demo:

1 DO:X=RND(0)*99:Y=RND(0)*62:C=RND(0)*64:MOVE X,Y:GFXHRND(0)*50

2 POKE$EC,C:LOOP



Older Updates:

Now with Transparent Sprite command GFXT

![Sprites](https://raw.githubusercontent.com/Fifty1Ford/BeEhBasic/main/TransparentSprites.gif) 


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

![Sprites](https://raw.githubusercontent.com/Fifty1Ford/BeEhBasic/main/BasicBallss.gif)

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
