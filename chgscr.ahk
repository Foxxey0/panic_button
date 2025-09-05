; TROUBLESHOOTING: if the hotkey for hiding ever stops running the code (first line doesnt run), the problem is probably the text file being too big (about 6 kb or 812 lines). i dont understand why, but it just happens. the fix is to delete the file and then the hotkey works fine again.



#Requires AutoHotkey v2.0
#WinActivateForce
; #NoTrayIcon

; TODO: Add threading so stuff happens at same time, quicker and safer.
; TOTO: hide the taskbar instances. some apps keep the taskbar instance. like Calculator and Roblox (Appstore App)

; DONE: hide sound too. EDIT: Its not fast enough. :(
; DONE: After hiding stuff, sometimes it comes right back up. why?? EDIT: I KNOW! IT TAKES A LONG TIME BECAUSE THERE ARE SO MANY COPIES OF THE SAME THING! I need to make it so theres only one instance of each id. I did it and its a lot faster now but apparently its not lightning fast even when theres only a few windows it needs to open. I guess WinShow() is just slow. :(
; DONE: stop it from making the desktop black
; DONE: unhide windows from END OF FILE FIRST since thats where the recently hidden window ids will be.

; Panic button is Left Alt
; hides all windows except one which it will go to. tries to hide incriminating ones, and JUTS in case hiding them fails, ill cover it up by making active another one
; THERES A REASON I OPEN THE GOTO WINDOW FIRST BEFORE HIDING THE OTHERS!!! Its because hiding a window plays a short animation. its short but every milisecond counts. its faster to hide stuff by opening the goto window first.

HasVal(haystack, needle) {

	if !(IsObject(haystack)) || (haystack.Length = 0) {
        return 0
    }

	for index, value in haystack {
		if (value = needle) {
			return index
        }
    }

    return 0

}

silenceWindow(id) {

    outputPID := 0 ; not really needed. But id rather have it cuz it looks cool,
    Run("nircmd-x64\nircmd.exe setappvolume /" . WinGetPID(id) . " 0", A_WorkingDir, "Max", &outputPID)

}
hideWindow(hiddenWindows, id) {

    WinHide(id) ; make disappear from screen
    ; make taskbar instance disappear
    ; MsgBox(id . " " . WinGetPID(id) . " " . WinGetProcessName(id)) ; DEBUG
    hiddenWindows.Push(id)

}

debounce := 1

; *Tab::
*LAlt:: {

    ; MsgBox("test1348") ; DEBUG

    global debounce

    ; if !debounce {
    ;     return
    ; }
    debounce := 0
    
    ; ; DEBUG
    ; Run "notepad"
    ; MsgBox ThisHotkey

    ; get window to go to (cover up.)
    Integer gotoID := 0

    ; ; 1. try visual studio code
    ; gotoID := WinExist("ahk_exe code.exe")

    ; if !gotoID or gotoID = currentID { ; doesnt exist OR its the current one that we closed (we dont wanna open it again because the fact it was the active window means i likely wanted to hide it).

    ;     ; 2. try calculator
    ;     gotoID := WinExist("Calculator ahk_exe applicationframehost.exe")

    ;     if !gotoID or gotoID = currentID {

    ;         ; 3. try task manager
    ;         gotoID := WinExist("ahk_exe taskmgr.exe")

    ;         if !gotoID or gotoID = currentID {

    ;             ; 4. try firefox
    ;             gotoID := WinExist("ahk_exe firefox.exe")

    ;             if gotoID = currentID {

    ;                 gotoID := 0

    ;             }
        
    ;         }   
    
    ;     }

    ; }

    currentWin := WinExist("A")
    ; MsgBox("current: " . currentWin . ", name: " . WinGetProcessName(currentWin)) ; DEBUG



    ; 0. try firefox
    gotoID := WinExist("ahk_exe firefox.exe")

    if !gotoID or gotoID = currentWin or WinGetMinMax(gotoID) != 1 {

        ; 1. try task manager
        gotoID := WinExist("ahk_exe taskmgr.exe")

        if !gotoID or gotoID = currentWin or WinGetMinMax(gotoID) != 1 {
        
            ; 2. try calculator
            gotoID := WinExist("Calculator ahk_exe applicationframehost.exe")

            if !gotoID or gotoID = currentWin or WinGetMinMax(gotoID) != 1 {

                ; 3. if theres nothing, then open taskmngr
                ; processID := 0
                ; Run("C:\Windows\System32\Taskmgr.exe", , , &processID)
                gotoID := 0

            }

        }

    }

    ; MsgBox("gotoid: " . gotoID . ", name: " . WinGetProcessName(gotoID)) ; DEBUG

    ; open goto window
    if (gotoID) { ; if the goto is the same as current, then current overrides it because i wouldnt usually do this unless i wanna hide it. i already tested for this before, but i just wanna be safe.

        ; TODO: needs to happen faster instead of an animation
        ; WinRestore(gotoID)
        WinActivate(gotoID)
        WinMaximize(gotoID) ; we shouldnt have to maximize it. but this is JUST in case. After all, we do want to cover up the entire screen.

    }

    Array hiddenWindows := [] ; to keep track of hidden ones so they can be opened again later

    ; ; silence current first (its usually the most incriminating)
    ; if currentID {

    ;     silenceWindow(currentID)

    ; }

    ; ; silence everything else just in case (except firefox and opera since they usually arent ever incriminating sounding)
    Array windows := WinGetList()

    ; if (gotoID) {

    ;     for iteration, id in windows {

    ;         if id = gotoID {
    ;             continue
    ;         }

    ;         if id = currentID { ; we already hid it first, we dont need to waste resources and time on trying to hide it again
    ;             continue
    ;         }

    ;         String name := WinGetProcessName(id)
    ;         String class := WinGetClass(id)

    ;         if name = "explorer.exe" and class != "cabinetwclass" { ; dont stop visual processes like desktop and taskbar. cabinetWClass is the file explorer and i DO want to hide that one. but not other explorer processes which handle visuals.
    ;             ; MsgBox(id . " " . WinGetProcessName(id) . " " . WinGetClass(id)) ; DEUBG
    ;             continue
    ;         }

    ;         if name = "firefox.exe" or name = "opera.exe" {

    ;             continue

    ;         }

    ;         silenceWindow(id)

    ;     }

    ; } else {

    ;     for iteration, id in windows {

    ;         if id = currentID { ; we already hid it first, we dont need to waste resources and time on trying to hide it again
    ;             continue
    ;         }

    ;         String name := WinGetProcessName(id)
    ;         String class := WinGetClass(id)

    ;         if name = "explorer.exe" and class != "cabinetwclass" { ; dont stop visual processes like desktop and taskbar. cabinetWClass is the file explorer and i DO want to hide that one. but not other explorer processes which handle visuals.
    ;             ; MsgBox(id . " " . WinGetProcessName(id) . " " . WinGetClass(id)) ; DEUBG
    ;             continue
    ;         }

    ;         if name = "firefox.exe" or name = "opera.exe" {

    ;             continue

    ;         }

    ;         silenceWindow(id)

    ;     }

    ; }

    ; hide others now
    if (gotoID) {

        for iteration, id in windows {

            if id = gotoID {
                continue
            }

            if !WinExist(id) { ; I dont understand why, but somehow, there was an error where the target (id) was not found. so im adding this check to make sure it doesnt happen again.

                continue

            }

            try {
                String name := WinGetProcessName(id) ; this has failed on my computer at dads house. it said access denied. so i added this try catch. works fine now. i guess certain programs dont give access to their process name.
            } catch Error as e {
                
            }

            String class := WinGetClass(id)

            if name = "explorer.exe" and class != "cabinetwclass" { ; dont stop visual processes like desktop and taskbar. cabinetWClass is the file explorer and i DO want to hide that one. but not other explorer processes which handle visuals.
                ; MsgBox(id . " " . WinGetProcessName(id) . " " . WinGetClass(id)) ; DEUBG
                continue
            }

            hideWindow(hiddenWindows, id)

        }

    } else {

        for iteration, id in windows {

            if !WinExist(id) { ; I dont understand why, but somehow, there was an error where the target (id) was not found. so im adding this check to make sure it doesnt happen again.

                continue

            }

            String name := WinGetProcessName(id)
            String class := WinGetClass(id)

            if name = "explorer.exe" and class != "cabinetwclass" { ; dont stop visual processes like desktop and taskbar. cabinetWClass is the file explorer and i DO want to hide that one. but not other explorer processes which handle visuals.
                ; MsgBox(id . " " . WinGetProcessName(id) . " " . WinGetClass(id)) ; DEUBG
                continue
            }

            hideWindow(hiddenWindows, id)

        }

    }

    ; saved hidden window ids to be opened later. even after a computer restart. because it saved ids to a file.
    ; idFile := FileOpen("hiddenIDs_" . A_Now . ".txt", "w")
    idFile := FileOpen("hiddenIDs.txt", "a")

    for iteration, id in hiddenWindows {

        idFile.Write(id . "`n")

    }

    idFile.Close()

    debounce := 1

}

debounce2 := 1

RControl & RShift:: {

    global debounce2

    ; if !debounce2 {
    ;     return
    ; }
    debounce2 := 0

    ; SendInput("d {Down}") ; just testing something for fun

    if !FileExist("hiddenIDs.txt") {
        MsgBox "no exist"
        debounce2 := 1
        return
    }

    idFile := FileOpen("hiddenIDs.txt", "r")
    ids := []

    ; extract all ids from the file
    String id := ""
    while (true) {

        id := idFile.ReadLine()

        if (id = "") {
            break
        } else {
            ids.Push(Integer(id))
        }

    }

    idFile.Close()

    ; filter the array (make sure theres only one instance of every id)
    ids_filtered := []

    for iteration, id in ids {

        if !HasVal(ids_filtered, id) {

            ids_filtered.Push(id)

        }

    }

    ; ; DEBUG
    ; String string273 := ""
    ; for iteration, id in ids_filtered {

    ;     string273 .= String(id) . "`n"

    ; }
    ; MsgBox(string273)

    ; Array windows := WinGetList()

    ; for iteration, id in windows {

    ;     MsgBox iteration . " " . WinGetProcessName(id)
    ;     WinShow(id)
    ;     WinActivate(id)

    ; }

    ; for iteration, id in ids {

    ;     if WinExist(id) {

    ;         WinShow(id)

    ;     }
    ;     ; MsgBox(id) ; DEUBG

    ; }

    ; open (unhide) each one FROM THE END OF FILE so its quicker. the more recent ones are at end of file.
    Integer index := ids_filtered.Length

    while (true) {

        if index <= 0 {

            ; MsgBox("test") ; DEBUG
            break

        }

        id := ids_filtered[index]

        if WinExist(id) {

            WinShow(id)
            ; Run("nircmd-x64\nircmd.exe setappvolume /" . WinGetPID(id) . " .2", A_WorkingDir, "Max", &outputPID)
            ; MsgBox(id . " " . WinGetProcessName(id) . " " . WinGetClass(id)) ; DEUBG

        }

        index -= 1

    }

    debounce2 := 1

}