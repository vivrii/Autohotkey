#Requires AutoHotkey v1.1.0+
#SingleInstance Force

#Include, readConfig.ahk

config := ReadConfigSection("resolutionChanger")

; turn off monitor
^!m::
    Sleep 1000
    SendMessage, 0x112, 0xF170, 2,, Program Manager
Return

^!p::
    ChangeResolution(32,config["screenWidthPx"],config["screenHeightPx"],config["lowHz"])
    ChangeResolution(32,config["screenWidthPx"],config["screenHeightPx"],config["highHz"])
Return

ChangeResolution( cD, sW, sH, rR )
{
    VarSetCapacity(dM,156,0), NumPut(156,2,&dM,36)
    DllCall( "EnumDisplaySettingsA", UInt,0, UInt,-1, UInt,&dM ),
    NumPut(0x5c0000,dM,40)
    NumPut(cD,dM,104), NumPut(sW,dM,108), NumPut(sH,dM,112), NumPut(rR,dM,120)
    Return DllCall( "ChangeDisplaySettingsA", UInt,&dM, UInt,0 )
}
