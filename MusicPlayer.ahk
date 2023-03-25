#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
Init:
Instruments := ListInstruments()

DisplayedSongs := []
SongPlayed := ""
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

OnExit, ExitSub
Return

ExitSub:
Gosub, CloseScript
ExitApp

GuiSize:  ; Expand or shrink the ListView in response to the user's resizing of the window.
if (A_EventInfo = 1)  ; The window has been minimized. No action needed.
    Return
; Otherwise, the window has been resized or maximized. Resize the ListView to match.
GuiControl, Move, PlaySong, % "W" . (A_GuiWidth - 20) . " H" . (A_GuiHeight - 50)
Return

GuiClose:  ; Indicate that the script should exit automatically when the window is closed.
ExitApp

MakeInstrumentsButtons:
    array := []
    Loop, Files, Images\Instruments\*.png, FR
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
        Gui, Add, Picture, %opt% w50 h-1 gFilterByInstrument v%name%, Images\Instruments\%name%.png
    }
    
    Gui, Add, Button, ym h50 gClearFilter, Clear Filter
Return

ClearFilter:
    Gosub, AddAllSongs
Return

FilterByInstrument:
    LV_Delete()
    DisplayedSongs := []
    For instrument, instrumentSongs in Songs
    {
        if (instrument == A_GuiControl) {
            For index, song in instrumentSongs
            {
                icon := "Icon1"
                If (InStr(SongPlayed, song))
                {
                    icon := "Icon2"
                }
                LV_Add(icon, song, instrument)
                DisplayedSongs.Push(song)
            }
        }
    }
Return

MakeListView:
    Gui, Add, ListView, x10 r20 w325 Sort Grid BackgroundE1E1E1 gPlaySong vPlaySong, Name|Instrument
    ImageListID := IL_Create(2)  ; Create an ImageList to hold 10 small icons.
    LV_SetImageList(ImageListID)  ; Assign the above ImageList to the current ListView.
    IL_Add(ImageListID, "Images\Play.png", 0)
    IL_Add(ImageListID, "Images\Stop.png", 1)

    Gosub, AddAllSongs
    LV_ModifyCol(1)
    LV_ModifyCol(2, 65)
Return

AddAllSongs:
    LV_Delete()
    DisplayedSongs := []
    For instrument, instrumentSongs in Songs
    {
        For index, song in instrumentSongs
        {
            icon := "Icon1"
            If (InStr(SongPlayed, song))
            {
                    icon := "Icon2"
            }
            LV_Add(icon, song, instrument)
            DisplayedSongs.Push(song)
        }
    }
Return

PlaySong:
if (A_GuiEvent = "DoubleClick")  ; There are many other possible values the script can check.
{
    Gosub, StopSong
    LV_GetText(FileName, A_EventInfo, 1) ; Get the text of the first field.
    LV_GetText(FileDir, A_EventInfo, 2)  ; Get the text of the second field.
    LV_Modify(A_EventInfo, "Icon2")
    SongPlayed := FileDir . "\" . FileName . ".ahk"

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

StopSong:
if (SongPlayed != "")
{
    GoSub, CloseScript
    Loop % LV_GetCount()
    {
        LV_GetText(RetrievedText, A_Index)
        if InStr(SongPlayed, RetrievedText)
        {
            LV_Modify(A_Index, "Icon1")
        }
    }
}
Return

CloseScript:
SplitPath, SongPlayed, Name
DetectHiddenWindows On
SetTitleMatchMode RegEx
IfWinExist, i)%Name%.* ahk_class AutoHotkey
{
    WinClose
    WinWaitClose, i)%Name%.* ahk_class AutoHotkey, , 2
    If ErrorLevel
        OutputDebug, % "Unable to close " . Name
    else
        OutputDebug, %  "Closed " . Name
} else
    OutputDebug, %  Name . " not found"
Return

ListInstruments()
{
    array := []
    Loop, Files, *, D
    {
        if (SubStr(A_LoopFileName, 1, 1) != .) && (A_LoopFileName != "Images\Instruments\") {
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