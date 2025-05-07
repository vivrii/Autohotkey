ReadConfigSection(sectionName) {
    ; choose which config file to use
    exampleConfigFile := "./config/example_ahk.config"
    configFile := "./config/ahk.config"

    if (!FileExist(configFile)) {
        if (FileExist(exampleConfigFile)) {
            FileCopy, %exampleConfigFile%, %configFile%, 0
            MsgBox, , Creating User Config, % "User config file has not yet been created.`nCreated at: " configFile
        } else {
            MsgBox, , Load Config Error, user config file (%configFile%) has not yet been created,`nbut the example config file (%exampleConfigFile%) is missing.
        }
    }

    IniRead, configSection, %configFile%, %sectionName%

    config := {}

    Loop, Parse, configSection, `n, `r
    {
        line := A_LoopField
        if (RegExMatch(line, "^(.*?)=(.*?)$", match)) {
            key := Trim(match1)
            value := Trim(match2)
            config[key] := value
        }
    }

    return config
}
