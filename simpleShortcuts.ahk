#Requires AutoHotkey v2.0
#SingleInstance Force

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
