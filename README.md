# <img width="48" height="48" align="center" src="https://cdn.discordapp.com/emojis/1528790285771997375.webp?size=44"> CalamusInjector
**A mod-menu/injector for OneShot with a plenty of mod menu options.**
Tags [for better reachability]: OneShot, OneShot mod menu, OneShot debug, OneShot mod, OneShot menu, OneShot, Ruby language, ruby coding language, ruby code, rpg maker xp, RPG maker xp, 

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/frizzy-cmd/CalamusInjector?color=blue&label=release)](https://github.com/frizzy-cmd/CalamusInjector/releases)
[![Platform](https://img.shields.io/badge/platform-windows%20%7C%20linux%20%7C%20mac-purple)](#)
[![Game version](https://img.shields.io/badge/game-OneShot-orange)](#)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

**I recommend you PLEASE do NOT use this tool if you haven't completed the full game w/ the Solstice route. There's nothing stopping you, but it's highly highly recommended to do so.**

### **Also, This has been tested working on Windows, I am unsure of Linux or Mac support though.**

---

## What does Calamus Injector have?
### **Mod menu options! They will be listed under here.**
- **Item ID giver:** You can instantly spawn items using their specific IDs, (IDs will be listed in `CalamusInjector/itemids.txt`!) You can spawn a bottle of alcohol, wet sponge, or wool, well almost anything! (in the game)
- **Item ID injector:** You can input a custom Item ID (01-82) to obtain hidden or hard to obtain items thru the mod menu!
- **Walk anywhere:** This is the key feature that I personally love! You can clip thru ANYTHING. Allowing Niko to go thru walls, barriers, and more!
- **Item ID remover:** Don't want something in your inventory? Shame. You can delete it using this feature in the mod menu!
- **Map ID jump system:** You can bypass progression by force-teleporting Niko to any Map ID (001-999) instantly! Spawning at X:15 Y:15 for every map, since i dont want to build a system where it can detect walkable area, Usually, X:15 Y:15 is the OK area for most maps to walk around!
- **Engine FPS unlocker:** This is more of a ***fun*** thing rather than useful, Normally, the engine is set to 60 FPS, like the usual, but if you set it to 9999 (which is the limit), everything goes by SUPER fast.
- **Force-saver:** Busy, or need to sleep but you haven't saved your game properly yet by letting Niko sleep? Use the **Force-save** feature! Forcefully writes to `%appdata%/Oneshot/save.dat` [or whereever your oneshot save file dir is at]
- **Verbose diagnostics:** You can toggle diagnostics in the mod menu easily, It displays: Current map ID, Coordinates, Player direction, Coordinates, Player sprite, Dialogue sprite, Current bgm, Engine FPS, Save count. Also displays the version of CalamusInjector.
- **BGM jukebox:** You can customize what background music you want! Go to `CalamusInjector/musicids.txt` for the list of the available IDs, or, go to your OneSHot game directory and find `calamus_bgm_log.txt`!
- **Mute BGM:** Alongside BGM jukebox, if you dont like a specific BGM (for some reason), or need to mute the BGM, you can use this! It does not mute any other sounds (e.g footsteps, dialogue, etc). Only the BGM.
- ..and more soon!


## Installation:
- **Make sure to backup your original `xScripts.rxdata` file and the `save.dat` file wherever OneShot stores your save files!**
- Go to the `Releases` section, and download `xScripts.rxdata`.
- Navigate to your OneShot game directory, which on Windows is normally at
- ```
  C:\Program Files (x86)\Steam\steamapps\common\OneShot\Data
  ```
- If you are using Linux or Mac, please Google what it is for you, or search it yourself.
- Move your unmodified `xScripts.rxdata` file out the `Data` folder.
- Drop the CalamusInjector version of the `xScripts.rxdata` file into the `Data` folder.
- Also make sure that your keybinds are set to this! Optional, but please make sure the R keybind is set to R.
- <img width="703" height="538" alt="image" src="https://github.com/user-attachments/assets/35d486a6-21a3-41e7-970a-289d332f0c35" />


## How to use CalamusInjector?
- Press `R` in-game to toggle the mod menu UI.
- Use your ACTION keybind to navigate.
- Enjoy and tinker around! :D

Preview:
<img width="645" height="513" alt="image" src="https://github.com/user-attachments/assets/d45cc28c-c995-47d0-92ab-664bbfabb502" />

Diagnostics UI:
<img width="631" height="512" alt="image" src="https://github.com/user-attachments/assets/22522303-fae5-40d0-906e-e2790532d781" />

BGM jukebox:
<img width="644" height="509" alt="image" src="https://github.com/user-attachments/assets/5cb53013-11f9-4c91-839f-9364a867dce5" />

---

# ⚠ General problems
Problem: OneShot immediately crashes with a error, or pressing R doesn't open the menu.
- Make sure you have replaced your unmodified xScripts.rxdata with the CalamusInjector xScripts.rxdata version, Or, if in some cases, OneShot pushed an update (not to my knowledge) that broke the injector. As of now, 20/07/2026, all functionality of CalamusInjector is working fine.
- And, to end your game if the game crashed, (since you can't close normally thru the X button during crashes), you will have to open Task Manager manually, and end the process there.

Problem: I used the Map ID jumper/walk anywhere/item id injector and i'm suddenly stuck out of bounds/a flag breaks/the game fails to save.
- OneShot is a heavily state-driven game that uses specific switches and variables to keep track of the current storyline. Forcing a map ID jump or giving yourself a item withour actually triggering the proper preceding events may confuse the engine. If you try to fix it with every method to no avail, you may have to reset your save files.

Problem: Windows Defender/my antivirus flags the injector (.rxdata) as a virus
- This shouldn't happen, since it's not happening for me on Windows Defender, (W10 LTSC), Add the .rxdata as a exclusion to the antivirus. I assure you it's safe, literally open source. If you don't trust me, you can extract the .rxdata and find out, or look at `.rb` file i uploaded.

**If a problem you are having is not listed here, please contact me, or try to fix it yourself.**
