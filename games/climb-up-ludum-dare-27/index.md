---
layout: nes
title: Climb Up! (Ludum Dare 27)
type: game
rom: climb-up.nes
shortname: climb-up-ludum-dare-27
date: 2015-01-01
---

Objective
---------
Your character will die in 10 seconds. Your goal is to get your character to escape the room by jumping out of the hole in the ceiling.

If your character dies, a new character will spawn, and will be able to push around and jump on top of the dead body of the old character. How many characters have to die before you can get one to the exit?

Use left and right to move the character and push obstacles. Use the A button (mapped to the X key) to jump.


Background
----------
*Climb Up!* was my first attempt not only at making a game on the *NES*, but it was also my first entry in *[Ludum Dare][]*, a 48-hour game development competition held four times a year. The theme was "10 seconds", but I also incorporated another theme that I thought was pretty cool, "death is useful". I developed the entire game using my *[#8bitmooc][]* toolchain for development and debugging as a kind of proof of concept and PR stunt, and for the most part, it was a success.

Needless to say, attempting to develop a game in 6502 assembly for the first time in one weekend on my own toolchain was an ambitious task, but it [paid off][]: my game was ranked 197th out of 2213 games for innovation, putting it in the top 10% of the most innovative games of the competition. I received piles of comments congratulating me for being able to produce a complete game, even if it was a bit buggy.

There were some comments on some features that would have definitely improved the game. For example, a timer that keeps track of how long your character has left to live as well as a button you could press to die early instead of having to wait for the full 10 seconds. However, I feel that by leaving out these convenient features, the game is more pure to the kinds of unfairly difficult games that were common on the good old *NES*.

My game was written in a way that made it work on emulators but in a way that it would not work on real hardware. I sent my game to some expert *NES* hackers on a [forum][] for NES development to get some feedback on how to improve my game so that it was more authentic and got some really great feedback.



[Ludum Dare]: http://ludumdare.com/
[#8bitmooc]: http://github.com/isharacomix/8bitmooc
[paid off]: http://ludumdare.com/compo/ludum-dare-27/?action=preview&uid=23902
[forum]: http://forum.nesdev.com
