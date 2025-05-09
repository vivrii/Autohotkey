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
    clipped := A_Clipboard

    pattern := "(?i)\b((?:[a-z][\w-]+:(?:/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'.,<>?«»“”‘’]))"
 
    if (exists_val := FileExist(clipped))
    {
        Run clipped
    }
    
    else if (RegExMatch(clipped, pattern, &urls))
    {
        Run urls[0]
    }
}

get_path_from_clipboard() {
    clipped := A_Clipboard
 
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

