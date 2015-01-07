---
layout: gb
title: Moving Around
type: demo
rom: moving.gb
shortname: moving-around
date: 2015-01-07
---

As much fun as I have fiddling about with assembly programming, even the most avid of assembly fans have to admit that it's a tedious process. It takes a while to get started since you end up having to do a lot of reading just to write a tiny little bit of code - the difficulty of getting something to appear on the screen at all makes incremental *Hello Worlds* rather difficult. Yesterday, I attended the Triangle Python User Group's [project night][] and focused on what I thought was a fairly simple task: making a character move on the screen according to user input. This turned out to be a lot more difficult than I thought it would be, but diving in head-first is a very powerful learning experience in the grand scheme of things.


User Input on the *Game Boy*
----------------------------
Unlike the *NES*, which has a one-bit wide bus between the controller and the console to transfer button presses, the *Game Boy* actually has enough wires to transmit the states of four buttons each time the joypad register is read. In order to determine which four buttons are read, there are two lines that act as "filters" - when the filter is off, those are the buttons that are read.

```
        P14     P15
 P10    Right   A
 P11    Left    B
 P12    Up      Select
 P13    Down    Start

          WWRRRR
  $FF00 76543210
           \\\\\\_P10: Right/A
            \\\\\_P11: Left/B
             \\\\_P12: Up/Select
              \\\_P13: Down/Start
               \\_P14: Filters D/U/L/R
                \_P15: Filters St/Se/B/A

```

In other words, in order to read the D-pad, you set P14 to 0 and P15 to 1. (```$FF00 = %0010000```). Then you read ```$FF00``` and mask the high four bits. Note that the readings are inverted from what you might think: a 0 means the button is pressed.

One more catch: in order for your reading to be accurate, some time has to pass between setting the filter and reading - it turns out that just reading the location six times does the trick. After doing this for both sides, join your two readings together and return P14 and P15 to their original states of both being 1.


Figuring it out last night
--------------------------
A lot of the challenges for retro game console development come from the piecemeal documentation floating around the Internet. Missing, inconsistent, and flat-out wrong documentation comes with the territory. Furthermore, a lot of the documentation is written from a hardware and emulation point of view with an emphasis on how the system works rather than a clear description of how to write new programs for it.

Luckily, there's plenty of example code, but even that has it's limitations. Originally, I wanted to have my own image moving around on the screen. However, I was using the *[Hello World][]* as my template to help speed me through some of the boilerplate, limiting my ability to learn how to draw things to the background on my own. As such, I compromised and thought that a scrolling "Hello World" marquee would settle for a proof of concept.

Originally, it scrolled so fast and refreshed so quickly that you couldn't see anything. Even when I figured out how to limit the main loop so that it would only run once per frame, it was still going too fast. My first idea was to only run the main loop every 5 frames, but that had a problem that if you pressed enter during a skipped frame, it wouldn't take effect. Eventually, I settled on a cooldown timer that would prevent the keypress code from running until 10 frames passed since the last keypress. I'm pretty content with the effects, but there are probably more elegant ways to do what I did in this last demo.


Next Steps
----------
I really need to brush up on my Z80 assembly. The Z80 has a completely different set of opcodes and way more registers than the good old 6502, so I need to get familiar with them so that programming isn't such a pain. I'm a little sad that I haven't found a good reference for Z80 opcodes like the [one I used][] for the 6502. But I'll figure it out, even if it means writing it up myself.



[project night]: http://tripython.org/Members/sgambino/jan-15-rpn/
[Hello World]: {{site.baseurl}}/demos/hello-gameboy
[one I used]: http://www.6502.org/tutorials/6502opcodes.html
