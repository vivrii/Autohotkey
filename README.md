# Installation (+ startup.ahk)

requires autohotkey 1 and 2 for all the scripts in this repo.

I use this by cloning anywhere, then making a shortcut to startup.ahk and placing that in the start up folder: 
`C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup`
then changing startup.ahk to only include the scripts you actually want, simples.

**TODO**: compile scripts and make a release for running without autohotkey installed

# simpleShortcuts.ahk
Simply some shortcuts I wanted

## Win + T
open windows terminal, that's it

## Win + Shift + T
open windows terminal, that's it ---UNLESS you have a valid path copied in ur clipboard, then you open a terminal at 
that location---

## Win + Shift + G
same as Win + Shift + T however the terminal is opened to the profile named: "Git Bash"

## Win + Shift + V
acts on the contents of the clipboard, so far only supports local files and "urls"

### the locals:
- if folder, it'll be opened in explorer
- if file, it will be attempted to run

### the urls:
- uses some regex string to find and launch the first url in the clipborad contents
- although in python this regex finds all urls, I could only get it to find the first one properly, ideally it would 
open all urls in the clipboard... **TODO**

### anything else:
- anything that don't trigger the above conditions, will allow the user to run in powershell
- a confirmation message box will appear showing the clipboard contents which will be ran
- if the user confirms, a uniquely named windows terminal will spawn and upon detection (with a 3s timeout) ahk will paste and execute the contents

## Win + Shift + ~
Registers the active window as the "secret" window

## Win + ~
Toggles maximise/minimise on the "secret" window

## Ctrl + Alt + Delete
shutdown windows IMMEDIATELY

## Ctrl + Alt + Shift + Delete
reboot windows
prompts asking set windows as the default boot option
- need to set the id to your own windows identifier
- use `bcdedit /enum firmware` to find yours today

~ **TODO: need to make this a config file thing**

## Ctrl + Alt + Shift + Delete
reboot windows into an alternative boot option
- need to set the id to your own "alternative boot option" identifier
- use `bcdedit /enum firmware` again to find yours today

~ **TODO: need to make this a config file thing**

# virtualDesktopMove.ahk
This uses https://github.com/Ciantic/VirtualDesktopAccessor/ which can be downloaded 
[here](https://github.com/Ciantic/VirtualDesktopAccessor/releases/latest/download/VirtualDesktopAccessor.dll) 
(needs to be placed in `VirtualDesktopAHK/` for the script to work)

## Win + Ctrl + Shift + [Left || Right]
This moves the currently focused window to the next (right) or previous (right) virtual desktop. (i.e. add shift to the 
usual windows hotkley for switching desktops to bring a window to accompany you)

## Win + Ctrl + Shift + [Up || Down]
This shortcut is used to pin (up) / unpin (down) a window. It increments/decrements pin level (unpinned -> window pinned
 -> app pinned)

## Win + [1-9, 0]
This shortcut will immediately switch to the desktop at an index represented by the number pressed.
Uses the key order so 1 == index 0 and 0 == index 10.

## Win + Shift + [1-9, 0]
This shortcut will immediately switch to the desktop at an index represented by the number pressed while also bringing the currently focused window with you.
Uses the key order so 1 == index 0 and 0 == index 10.

## On WM_DISPLAYCHANGE
> Note: this is currently commented out and won't function without modification

### monitor count changed to be 1:
Any pinned windows will be unpinned and sent to the first virtual desktop
The ID of these will be stored in a list for later

### monitor count changed to be > 1:
Any ID found in the stored list, will be repinned

# resolutionChanger.ahk

## Ctrl + Alt + M
This turns off the monitor, that's all

## Ctrl + Alt + P
This would need to be configured for your monitors resolution + refresh rate. I use it because I had a lot of situations
where my 144 Hz monitor was using 60 Hz when playing certain games requiring me to switch it to 60 Hz then back to 144
Hz, this just does that for you (if your resolution is 5120x1440 and your 144 Hz is 24 0Hz...) if you need this, just 
change the numbers to what your numbers are, or really just do whatever makes you happy

# friendsRefresher.ahk
This was used to sign out and into steam friends when it would fail to keep statuses properly updated. haven't had this 
problem in a while and don't even keep the friends list open anymore so I haven't tested it in a while.

## Ctrl + Shift + F || a timer
It runs on a 30m timer which each trigger, will check if you were idle for at least 5m before refreshing the friends
list. It also makes sure you aren't in a fullscreen application.

or there is also the hotkey you can use to trigger it.

# Sources

OSDTIP.ahk comes from https://www.autohotkey.com/boards/viewtopic.php?f=6&t=76881 and is what I'm using for displaying 
toast notifications.

virtualDesktopMove.ahk is brought to you by https://github.com/Ciantic/VirtualDesktopAccessor/

