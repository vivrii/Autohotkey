#Include OSDTIP.ahk
#SingleInstance Force
#Persistent

; store the current monitor count
global monitor_count := 0
SysGet, monitor_count, MonitorCount
global unPinnedWindows := []

; watch event which will be triggered on display connect/disconnect
; https://www.autohotkey.com/docs/v1/misc/SendMessageList.htm
WM_DISPLAYCHANGE := 0x7E
OnMessage(WM_DISPLAYCHANGE, "DisplayChangeCallback")

VDA_PATH := A_ScriptDir . ".\VirtualDesktopAccessor.dll"
hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", VDA_PATH, "Ptr")

; this will be indexed from 0 up to 1 - desktop count
global GetCurrentDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetCurrentDesktopNumber", "Ptr")
; count will be number of desktops (i.e. 1 + max desktop index)
global GetDesktopCountProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopCount", "Ptr")
global GoToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GoToDesktopNumber", "Ptr")
global IsWindowOnDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsWindowOnDesktopNumber", "Ptr")
global MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "MoveWindowToDesktopNumber", "Ptr")

global IsPinnedWindowProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsPinnedWindow", "Ptr")
global PinWindowProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "PinWindow", "Ptr")
global UnPinWindowProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "UnPinWindow", "Ptr")
global IsPinnedAppProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsPinnedApp", "Ptr")
global PinAppProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "PinApp", "Ptr")
global UnPinAppProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "UnPinApp", "Ptr")

GetDesktopCount() {
    count := DllCall(GetDesktopCountProc, "Int")
    return count
}

MoveCurrentWindowToDesktop(desktopNumber) {
    WinGet, activeHwnd, ID, A
    DllCall(MoveWindowToDesktopNumberProc, "Ptr", activeHwnd, "Int", desktopNumber, "Int")
    DllCall(GoToDesktopNumberProc, "Int", desktopNumber)
}

GoToPrevDesktop() {
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

; if monitor count has changed, store new count and pin/unpin windows
; TODO:
; hotkey to toggle between having this option enabled and not doing this:
;   * any window on a non primary screen should be automatically pinned
;   * when moved to primary, it should be unpinned
DisplayChangeCallback(wParam, lParam)
{
    SysGet, current_monitor_count, MonitorCount

    if (current_monitor_count != monitor_count) {
        monitor_count := current_monitor_count
        if (monitor_count = 1) {
            unPinWindowsToFirst()
        } else if (monitor_count > 1) {
            rePinWindowsFromList()
        }
    }
}

;   * find all pinned windows and unpin them and send them to virtual desktop 0
;   * log the apps that got unpinned
unPinWindowsToFirst() {
    WinGet windows, List
    Loop %windows% {
        activeHwnd := windows%A_Index%
        windows_pinned := DllCall(IsPinnedWindowProc, "Ptr", activeHwnd, "Int")

        if (windows_pinned = 1) {
            ; window is pinned so add to list, un pin, send to first virtual desktop
            ; DllCall(UnPinWindowProc, "Ptr", activeHwnd, "Int")
            DllCall(MoveWindowToDesktopNumberProc, "Ptr", activeHwnd, "Int", 0, "Int")
            unPinnedWindows.Push(activeHwnd)
        }
    }
}

;   * use the log to set apps back to being pinned
;   * move them to full screen on second display
rePinWindowsFromList() {
    for key, activeHwnd in unPinnedWindows {
        DllCall(PinWindowProc, "Ptr", activeHwnd, "Int")
    }

    unPinnedWindows := []
}

Numbers := ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
for index, number in Numbers
{
    Hotkey, #%number%, GoToDesktopNumberHotkey
    Hotkey, #+%number%, MoveToDesktopNumberHotkey
}

GoToDesktopNumberHotkey() {
    key := SubStr(A_ThisHotkey, 2)
    index := InStr("1234567890", key)
    DllCall(GoToDesktopNumberProc, "Int", index - 1)
}

MoveToDesktopNumberHotkey() {
    key := SubStr(A_ThisHotkey, 3)
    index := InStr("1234567890", key)
    MoveCurrentWindowToDesktop(index - 1)
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

