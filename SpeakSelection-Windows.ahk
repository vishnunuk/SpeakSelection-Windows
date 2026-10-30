#Requires AutoHotkey v2.0
global voice := ComObject("SAPI.SpVoice")

; Press Alt + S to Speak
!s:: {
    SavedClip := ClipboardAll()
    A_Clipboard := ""
    Send "^c"
    if ClipWait(1) {
        voice.Speak(A_Clipboard, 1) 
    }
    Sleep 500
    A_Clipboard := SavedClip
}

; Press Alt + Q to Quit reading
!q:: {
    voice.Speak("", 3) 
}