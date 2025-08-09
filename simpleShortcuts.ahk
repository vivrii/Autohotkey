#Requires AutoHotkey v2.0
#SingleInstance Force

tempDir := A_ScriptDir "/temp"
if !DirExist(tempDir)
{
    DirCreate(tempDir)
}
tempFileIni := tempDir "/simpleShortcuts.temp"

#t::
{
    Run "wt.exe"
}

; win + shit + t
; if the clipboard item is a file/folder present on the system, open a terminal at that location
#+t::
{
    path := get_path_from_clipboard()
    if path
        Run "wt.exe --startingDirectory " "`"" path "`"" 
    else Run "wt.exe"
}

; win + shit + g
; if the clipboard item is a file/folder present on the system, open a git bash terminal at that location
;
;   ~ REQUIRES ~
;       adding a profile called "Git Bash" to windows terminal
;       setting Command line to "C:\Program Files\Git\bin\bash.exe" or similar
;       and optionally, set Icon to "C:\Program Files\Git\git-bash.exe" (show all files in the dialog and it will work)
#+g::
{
    path := get_path_from_clipboard()
    if path
        Run "wt.exe -p `"Git Bash`" --startingDirectory " "`"" path "`"" 
    else Run "wt.exe -p `"Git Bash`""
}



; win + shift + v
; if the clipboard item is a file present on the computer (or directory) run it
; if the clipboard item begins like a url, open it
#+v::
{
    clipped := RegexReplace(A_Clipboard, "^\s+|\s+$")

    pattern := "(?i)\b((?:(?!env:)[a-z][\w-]+:(?:/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'.,<>?«»“”‘’]))"
 
    if (exists_val := FileExist(clipped))
    {
        Run clipped
    }
    
    else if (RegExMatch(clipped, pattern, &urls))
    {
        Run urls[0]
    }

    else if MsgBox("Would you like to run the following clipboard contents in powershell?`n`n" clipped, "clipped runner", "YesNo Icon?") = "Yes"
    {
        uniqueTitle := "WT_" . A_TickCount
        Run("wt.exe --title " uniqueTitle)
        if (WinWait(uniqueTitle, , 3))
        {
            WinActivate(uniqueTitle)
            Send(clipped "`n")
        }
        else
        {
            MsgBox("", "didn't find windows terminal...", 0)
        }
    }
}

get_path_from_clipboard() {
    clipped := RegexReplace(A_Clipboard, "^\s+|\s+$")
 
    if (exists_val := FileExist(clipped))
    {
        if InStr(exists_val, 'D')
        {
            return clipped
        }
        else
        {
            RegExMatch(clipped, "(.*)(?=\\)", &folder)
            return folder[0]
        }
    }
}

global secretWindowId := 0
; doesn't exactly work when on another desktop,
; detect hidden allows it to act, but it wont restore to a different virtual desktop
; may move this into virtual desktop
; DetectHiddenWindows(true)

secretWindowPrint()
{
    procName := WinGetProcessName("ahk_id" secretWindowId)
    procTitle := WinGetTitle("ahk_id" secretWindowId)

    return "name: " procName "`ntitle: " procTitle
}

secretWindowRestore()
{
    WinShow("ahk_id" secretWindowId)
}

secretWindowHide()
{
    WinHide("ahk_id" secretWindowId)
}

; i hope there is a better way to do this...
secretWindowToggle()
{
    prev := A_DetectHiddenWindows
    exists := false

    try
    {
        DetectHiddenWindows(false)
        WinGetPos(&win_x,,,, "ahk_id" secretWindowId)

        ; window is real and can hurt you (not hidden)
        secretWindowHide()
        exists := true
    }
    catch
    {
        try
        {
            DetectHiddenWindows(true)
            WinGetPos(&win_x,,,, "ahk_id" secretWindowId)

            ; window is real and can't hurt you (hidden)
            secretWindowRestore()
            exists := true
        }
        catch 
        {
            exists := false
        }
    }
    
    DetectHiddenWindows(prev)
    return exists
}

secretWindowExists()
{
    prev := A_DetectHiddenWindows
    DetectHiddenWindows(true)

    exists := WinExist("ahk_id" secretWindowId)

    DetectHiddenWindows(prev)
    return exists
}

; detect if previous secret window was alive
; ensures script restart doesn't lose a window...
prev := A_DetectHiddenWindows
DetectHiddenWindows(true)
if FileExist(tempFileIni)
{
    savedId := IniRead(tempFileIni, "secretWindow", "id", 0)
    if (savedId && WinExist("ahk_id" savedId))
    {
        global secretWindowId := savedId
        TrayTip("registering previous secret window`n" secretWindowPrint())
    }
}
DetectHiddenWindows(prev)

; win + shift + ~
; register the active window as the secret window
#+`::
{
    global secretWindowId

    hwnd := WinExist("A")
    if !hwnd
    {
        TrayTip("did not find a window to secret...", "Secret Window", 0)
        return
    }

    if (secretWindowId && secretWindowId != hwnd && secretWindowExists())
    {
        secretWindowRestore()
    }

    secretWindowId := hwnd
    IniWrite(hwnd, tempFileIni, "secretWindow", "id")

    TrayTip("registered new secret window`n" secretWindowPrint(), "secretWindow", 0)
}

; win + ~
; toggle minimise/restore on the secret window
#`::
{
    if !secretWindowToggle()
    {
        TrayTip("no secret window to toggle...", "secretWindow", 0)
    }
}

; ctrl + alt + del
^!Delete::
{
    Run("shutdown /s /t 0")
}

; ctrl + alt + shift + Del
^!+Delete::
{
    if MsgBox("Make Windows default before rebooting?", "Switch Boot Target", "YesNo Icon?") = "Yes"
    {
        Run('*RunAs cmd.exe /c "bcdedit /set {fwbootmgr} bootsequence {42a46931-0404-11f0-bf98-806e6f6e6963}"')
    }
    Run("shutdown /r /t 0")
}

; ctrl + alt + shift + win + Del
^!+#Delete::
{
    Run('*RunAs cmd.exe /c "bcdedit /set {fwbootmgr} bootsequence {a60636e1-932b-11ed-bd63-806e6f6e6963} && shutdown /r /t 0"')
}
