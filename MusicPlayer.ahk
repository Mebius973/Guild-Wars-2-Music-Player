#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
Init:
Instruments := ListInstruments()

Songs := []
For key, value in Instruments
{
    Songs[value] := ListSong(value)
}

Gui, New,, "Guild Wars 2 Music Player"
Gui, Add, ListView, r20 w720 Sort Grid gPlaySong, Name|Instrument

For instrument, instrumentSongs in Songs
{
    OutputDebug, % instrument
    for index, song in instrumentSongs
    {
        LV_Add("", song, instrument)
    }
}   
LV_ModifyCol(1)
LV_ModifyCol(2, 65)

gui, show
return

PlaySong:
if (A_GuiEvent = "DoubleClick")  ; There are many other possible values the script can check.
{
    OutputDebug, % DoubleClick
    LV_GetText(FileName, A_EventInfo, 1) ; Get the text of the first field.
    LV_GetText(FileDir, A_EventInfo, 2)  ; Get the text of the second field.

    IfWinExist Guild Wars 2
    {
        WinActivate
    }
    Sleep, 1000

    Run %FileDir%\%FileName%.ahk,, UseErrorLevel
    if ErrorLevel
        MsgBox Could not open "%FileDir%\%FileName%".
}
return

ListInstruments()
{
    array := []
    Loop, Files, *, D
    {
        
        if SubStr(A_LoopFileName, 1, 1) != . {
            array.Push(A_LoopFileName)
        }
    }
    Return array 
}

ListSong(instrument)
{

    array := []
    Loop, Files, %instrument%\*.ahk, FR
    {
        array.Push(SubStr(A_LoopFileName, 1 , StrLen(A_LoopFileName) - StrLen(A_LoopFileExt) - 1))
    }
    Return array
}