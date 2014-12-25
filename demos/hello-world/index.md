---
layout: gb
title: Hello World!
type: demo
rom: hello.gb
shortname: hello-world
date: 2015-01-01
---

When most people write up a blog post, they usually put some fancy photo or infographic up front and center to draw the reader's attention to their words. However, on this page, up at the top, what you see in front of your eyes is no ordinary static image - this is an honest-to-goodness "Hello World" program running on a fairly accurate emulator of the Nintendo [Game Boy][]. Welcome to the future. Or the past. Or something.

This is the first entry in what I think I'm going to start calling my **interactive blog**: an online archive of demos and other diversions that offer a glimpse not only into what I'm thinking, but the things I create, while in the process of creating them. I've kept a fairly traditional blog for the last five years of my life, describing the things I've done in school, but it's recently grown to be tiring and just not much fun anymore.

As much as I enjoyed it, the problem with blogging for a long time is that you start to raise the expectations of your writing. Part of the joy of the blog was being able to write out a raw and unpolished stream of consciousness about whatever I was thinking about and call that a blog entry. I'm a fairly eloquent writer, so even nonsense dribble comes across as pleasantly insightful. But then I started building an audience that made me self-conscious about putting my flawed self on display. I felt like I needed to start acting with some dignity and start writing some critical and thoughtful self-contained essays, roughly once a month, turning writing from an outlet into uncompensated and unfulfilling labor.

I also found out that Twitter is a better place for the kind of spontaneous blogging that I had been doing anyway. I've got 8000 tweets now, you know!

What I want, more than anything, is what I consider a virtual workshop - a place I can go to work with my metaphorical hands and create artifacts that provide proof that I'm as smart as I like to think I am. My attention span doesn't keep me on many projects for long, most of the games and tools I work on in my spare time end up collecting dust as neat prototypes of unfinished concepts. Fun to fiddle around with and interesting in their own right, but lacking a sense of coherence and completion. I've always thought it'd be nice to share these kinds of things with the world, since they don't require much forethought to prepare and offer a refreshing glimpse of the creative process.

So what better artifact to begin this adventure with than an old-fashioned "Hello World"? I've recently been teaching myself how to write programs in Z80 assembly for the original Nintendo hand-held phenomenon: the Game Boy. I got my start with retro game programming with the Nintendo Entertainment System, but despite how much I love the 6502 processor, programming for the NES is messy. The Game Boy's clean and organized programming interface demonstrates that Nintendo actually learned something from the wild west early days of Atari and NES game development. Unlike the NES, the Game Boy has built in I/O, so it doesn't have to compromise with the way that televisions at the time worked. You get a lot more registers with the Z80. It's a very refreshing experience that still feels like NES programming, but a bit more mature.

These kinds of silly, game-like blog posts are things I like to call **[demos][]**, or little, interactive proofs of concepts that show very simple game mechanics written in assembly code. While this particular demo may not be much - not only does it not accept user input, the stray characters show that it's not even particularly cleaned up - the real thing I'm showing off is the integration of Grant Galitz's [Game Boy Online][] open source Javascript emulation of the platform built in to my Github pages and Jekyll blogging platform. In fact, I didn't even write the source code for this Hello World program either - it comes from a Game Boy assembly programming [tutorial][] I've been reading to pick up the basics of how to make these kinds of games. The Hello World is the ultimate proof of concept that demonstrates that I've successfully gotten my environment and tool chain properly configured, meaning that it is now safe to move forward to the next step.

I hope you'll stick around. You might find something you like and maybe even learn something! I might write some full-fledged games while I'm here, at least as parts of game jams like [Ludum Dare][]. If you have any questions or comments along the way, feel free to drop them in the box below.



[Game Boy]: https://en.wikipedia.org/wiki/Game_Boy
[demos]: {{site.baseurl}}demos/
[Game Boy Online]: https://github.com/grantgalitz/GameBoy-Online/
[tutorial]: http://gameboy.mongenel.com/asmschool.html
[Ludum Dare]: http://ludumdare.com
