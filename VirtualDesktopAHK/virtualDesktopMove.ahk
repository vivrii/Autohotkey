#Include OSDTIP.ahk
#SingleInstance Force

VDA_PATH := A_ScriptDir . ".\VirtualDesktopAccessor.dll"
hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", VDA_PATH, "Ptr")

; this will be indexed from 0 up to 1 - desktop count
GetCurrentDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetCurrentDesktopNumber", "Ptr")
; count will be number of desktops (i.e. 1 + max desktop index)
GetDesktopCountProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopCount", "Ptr")
GoToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GoToDesktopNumber", "Ptr")
IsWindowOnDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsWindowOnDesktopNumber", "Ptr")
MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "MoveWindowToDesktopNumber", "Ptr")

IsPinnedWindowProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsPinnedWindow", "Ptr")
PinWindowProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "PinWindow", "Ptr")
UnPinWindowProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "UnPinWindow", "Ptr")
IsPinnedAppProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsPinnedApp", "Ptr")
PinAppProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "PinApp", "Ptr")
UnPinAppProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "UnPinApp", "Ptr")

GetDesktopCount() {
    global GetDesktopCountProc
    count := DllCall(GetDesktopCountProc, "Int")
    return count
}

MoveCurrentWindowToDesktop(desktopNumber) {
    global MoveWindowToDesktopNumberProc, GoToDesktopNumberProc
    WinGet, activeHwnd, ID, A
    DllCall(MoveWindowToDesktopNumberProc, "Ptr", activeHwnd, "Int", desktopNumber, "Int")
    DllCall(GoToDesktopNumberProc, "Int", desktopNumber)
}

GoToPrevDesktop() {
    global GetCurrentDesktopNumberProc, GoToDesktopNumberProc
    current := DllCall(GetCurrentDesktopNumberProc, "Int")
    last_desktop := GetDesktopCount() - 1
    ; If current desktop is 0, go to last desktop
    if (current = 0) {
        MoveCurrentWindowToDesktop(last_desktop)
    } else {
        MoveCurrentWindowToDesktop(current - 1)
    }
    return
}

GoToNextDesktop() {
    global GetCurrentDesktopNumberProc
    current := DllCall(GetCurrentDesktopNumberProc, "Int")
    last_desktop := GetDesktopCount() - 1
    ; If current desktop is last, go to first desktop
    if (current = last_desktop) {
        MoveCurrentWindowToDesktop(0)
    } else {
        MoveCurrentWindowToDesktop(current + 1)
    }
    return
}

; no pin -> window pin -> app pin
IncrementPin() {
    global IsPinnedAppProc, IsPinnedWindowProc, PinWindowProc, PinAppProc
    WinGet, activeHwnd, ID, A

    window_pinned := DllCall(IsPinnedWindowProc, "Ptr", activeHwnd, "Int")
    if (window_pinned = -1) {
        OSDTIP_Alert("Increment Pin", "Failed to check if window is pinned", -500, "v4")
    } else if (window_pinned = 1) {
        ; if window pin, set app pin if not already pinned
        app_pinned := DllCall(IsPinnedAppProc, "Ptr", activeHwnd, "Int")
        if (app_pinned = 0) {
            result := DllCall(PinAppProc, "Ptr", activeHwnd, "Int")
            OSDTIP_Alert("Increment Pin", "pinned application", -500)
        }
    } else {
        ; if no window pin, set window pin
        result := DllCall(PinWindowProc, "Ptr", activeHwnd, "Int")
        OSDTIP_Alert("Increment Pin", "pinned window", -500)
    }
}

; app pin -> window pin -> no pin
DecrementPin() {
    global IsPinnedAppProc, IsPinnedWindowProc, UnPinAppProc, UnPinWindowProc, PinWindowProc
    WinGet, activeHwnd, ID, A

    app_pinned := DllCall(IsPinnedAppProc, "Ptr", activeHwnd, "Int")
    if (app_pinned = -1) {
        OSDTIP_Alert("Decrement Pin", "Failed to check if app is pinned", -500, "v4")
    } else if (app_pinned = 1) {
        ; if app pinned, un pin
        result := DllCall(UnPinAppProc, "Ptr", activeHwnd, "Int")
        result_pin := DllCall(PinWindowProc, "Ptr", activeHwnd, "Int")
        OSDTIP_Alert("Decrement Pin", "unpinned application", -500)
    } else {
        ; if not app pinned, unpin window
        window_pinned := DllCall(IsPinnedWindowProc, "Ptr", activeHwnd, "Int")
        if (window_pinned = 1) {
            result := DllCall(UnPinWindowProc, "Ptr", activeHwnd, "Int")
            OSDTIP_Alert("Decrement Pin", "unpinned window", -500)
        }
    }
}

^#+Left::
GoToPrevDesktop()
return

^#+Right::
GoToNextDesktop()
return

^#+Up::
IncrementPin()
return

^#+Down::
DecrementPin()
return