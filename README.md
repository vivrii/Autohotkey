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

## Win + Shift + V
acts on the contents of the clipboard, so far only supports local files and "urls"

### the locals:
- if folder, it'll be opened in explorer
- if file, it will be attempted to run

### the urls:
- uses some regex string to find and launch the first url in the clipborad contents
- although in python this regex finds all urls, I could only get it to find the first one properly, ideally it would 
open all urls in the clipboard... **TODO**

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

## On WM_DISPLAYCHANGE

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