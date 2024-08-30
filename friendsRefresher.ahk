#Persistent
#SingleInstance Force

SetTimer, friendRefreshTimer, 1800000

friendRefreshTimer:
    if (A_TimeIdle >= 300000) and not fullscreen()
    {
        gosub friendRefresh
    }
return

^+f::
    Sleep, 500
friendRefresh:
    Run, steam://open/friends
    Sleep, 333
    friendsPos()
    CoordMode, Mouse, Screen
    Click, 3306, 32, Right
    Sleep, 333
    Click, 3300, 150, Left
    friendsPos()
    Sleep, 333
    Click, 3297, 215, Left
    friendsPos()
return

friendsPos()
{
    WinWait, Friends List, , 5
    WinMove, Friends List, , 3139, 0, 301, 1392
}

fullscreen()
{
    WinGetPos,,, w, h, A
    return (w = A_ScreenWidth && h = A_ScreenHeight)
}