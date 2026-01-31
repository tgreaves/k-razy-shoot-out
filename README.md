# K-RAZY SHOOT OUT

Original game by Dr. Keith Dreyer and Torre Meede.

Published by CBS Electronics.

Disassembly and PICO-8 de-make by Tristan Greaves <tristan@extricate.org>

Please see LICENSE for full information.

## What is this?

This is a fully disassembly, commentary and PICO-8 de-make of one of my favourite Atari 5200 games. The original game is a clone of Berzerk, but IMHO, much better.

![Alt text](/screenshots/pico-8-screenshot.png?raw=true "Optional Title")

## Files to look at

- **reference/** - Original game manual, as well as a summary of the game mechanics
- **screenshots/** - Example game screenshots
- **sound/** - Scripts to generate WAV equivalents of the game audio
- **sprites/** - Scripts to extract images from the game, as well as generated sprite sheets
- **font/** - Custom font extraction and character mapping from the game's character set
- **pico8/** - A recreation of the game for the PICO-8 fantasy console

## The core disassembly

The main work is in K_RAZY_SHOOTOUT_ANNOTATED.asm.

This is not currently in a format where you can put it in a compiler for the Atari 5200 and it will work.

I've commented the game logic, loops etc as much as possible in here. It's still WORK IN PROGRESS as I work everything out.

Any input, especially from those that know more about the hardware than I do (not hard - this has been a real learning experience!), would be much appreciated.

## How was this done?

This work was done in conjunction with Amazon Kiro. It required a lot of coaching / teamwork to work through the game logic and understand the nature of the game.  

## Can I play this in PICO-8?

Yes, yes you can!  See the **pico8** directory for more information.

