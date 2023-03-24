#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
Init:
Instruments := ListInstruments()

DisplayedSongs := []
Songs := []
For key, value in Instruments
{
    Songs[value] := ListSong(value)
}

Gui, New,, "Guild Wars 2 Music Player"
Gosub, MakeInstrumentsButtons
Gosub, MakeListView

Gui +Resize
Gui, show
Return

MakeInstrumentsButtons:
    array := []
    Loop, Files, Images\*.png, FR
    {
        name := SubStr(A_LoopFileName, 1 , StrLen(A_LoopFileName) - StrLen(A_LoopFileExt) - 1)
        array.Push(name)
    }

    For index, image in array
    {
        name := array[index]
        opt := ""

        if (index > 1) {
            opt := "ym"
        }
        Gui, Add, Picture, %opt% w50 h-1 gButtonWithPicture v%name%, Images\%name%.png
    }
    
    Gui, Add, Button, ym h50 gClearFilter, Clear Filter
Return

ClearFilter:
    Gosub, AddAllSongs
Return

ButtonWithPicture:
    LV_Delete()
    DisplayedSongs := []
    For instrument, instrumentSongs in Songs
    {
        if (instrument == A_GuiControl) {
            For index, song in instrumentSongs
            {
                LV_Add("", song, instrument)
                DisplayedSongs.Push(song)
            }
        }
    }
Return

MakeListView:
    Gui, Add, ListView, x10 r20 w325 Sort Grid BackgroundE1E1E1 gPlaySong vPlaySong, Name|Instrument
    Gosub, AddAllSongs
    LV_ModifyCol(1)
    LV_ModifyCol(2, 65)
Return

AddAllSongs:
    DisplayedSongs := []
    For instrument, instrumentSongs in Songs
    {
        For index, song in instrumentSongs
        {
            LV_Add("", song, instrument)
            DisplayedSongs.Push(song)
        }
    }
Return

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
Return

GuiSize:  ; Expand or shrink the ListView in response to the user's resizing of the window.
if (A_EventInfo = 1)  ; The window has been minimized. No action needed.
    Return
; Otherwise, the window has been resized or maximized. Resize the ListView to match.
GuiControl, Move, PlaySong, % "W" . (A_GuiWidth - 20) . " H" . (A_GuiHeight - 50)
Return

GuiClose:  ; Indicate that the script should exit automatically when the window is closed.
ExitApp

ListInstruments()
{
    array := []
    Loop, Files, *, D
    {
        
        if (SubStr(A_LoopFileName, 1, 1) != .) && (A_LoopFileName != "Images") {
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