;AHKCSortie v1.61121

#Persistent
#SingleInstance
#Include %A_ScriptDir%/Functions/Gdip_All.ahk ;Thanks to tic (Tariq Porter) for his GDI+ Library => ahkscript.org/boards/viewtopic.php?t=6517

if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
   ExitApp
}
CoordMode, Pixel, Relative
Menu, Tray, Icon, %A_ScriptDir%/Icons/favicon_ahkcsortie.ico,,1

IniRead, Background, config.ini, Variables, Background, 1
IniRead, Class, config.ini, Variables, Class, 0

Initialize()

IniRead, WINID, config.ini, Variables, WINID, Nox

MiscDelay := 1000

;PixelColor Constants

#Include %A_ScriptDir%/Constants/PixelColor.ahk

BC := 0
BusyS := 0
TR := 0
DT := 0
Nodes := 1
Sortiecount := 0

IniRead, NotificationLevel, config.ini, Variables, NotificationLevel, 1
IniRead, TWinX, config.ini, Variables, LastXS, 0
IniRead, TWinY, config.ini, Variables, LastYS, 0
SpecificWindows()
IniRead, World, config.ini, Variables, World, %A_Space%
IniRead, Map, config.ini, Variables, Map, %A_Space%
IniRead, DisableCriticalCheck, config.ini, Variables, DisableCriticalCheck, 0
IniRead, Sparkling, config.ini, Variables, Sparkling, 0
IniRead, DisableResupply, config.ini, Variables, DisableResupply, 0
IniRead, SortieInterval, config.ini, Variables, SortieInterval, -1 ;900000 for full morale
IniRead, MinRandomWait, config.ini, Variables, MinRandomWaitS, 0
IniRead, MaxRandomWait, config.ini, Variables, MaxRandomWaitS, 300000
Gui, 1: New
Gui, 1: Default
Gui, Add, Text,, Map:
Gui, Add, Text,, MinWait:
Gui, Add, Text,, MaxWait:
Gui, Add, Edit, r1 w20 vNB ReadOnly
GuiControl, Move, NB, x10 w300 y80
Gui, Add, Edit, gWorldF r2 limit3 w10 vWorldV -VScroll ym, %World%
GuiControl, Move, WorldV, x37 h17 w15
Gui, Add, Text, x55 ym, -
Gui, Add, Edit, gMapF r2 limit3 w10 vMapV -VScroll ym, %Map%
GuiControl, Move, MapV, x62 h17 w20
Gui, Add, Text, ym, Interval(ms):
Gui, Add, Edit, gIntervalF r2 w15 vIntervalV -VScroll ym, %SortieInterval%
GuiControl, Move, IntervalV, h17 w70
Gui, Add, Checkbox, vExpeditionV , Expedition only
GuiControl, Move, ExpeditionV, x150 y33
; Gui, Add, Text, vText, #Nodes
; GuiControl, Move, Text, x150 y35
; Gui, Add, Edit, gNodeCount r2 limit3 w10 vNodeCount -VScroll ym, %Nodes%
; GuiControl, Move, NodeCount, x195 y33 h17 w25
Gui, Add, Button, gSSBF vSSB, A
GuiControl, Move, SSB, x250 w60 ym
GuiControl,,SSB, Start
Gui, Add, Edit, gMiW r2 w20 vmid -VScroll, %MinRandomWait%
GuiControl, Move, mid, h20 x60 y30 w80
Gui, Add, Edit, gMaW r2 w20 vmad -VScroll, %MaxRandomWait%
GuiControl, Move, mad, h20 x60 y55 w80
Menu, Main, Add, Pause, Pause2
Menu, Main, Add, 0, DN
Gui, Menu, Main
Gui, Show, X%TWinX% Y%TWinY% Autosize, Gunkolle
Gui -AlwaysOnTop
Gui +AlwaysOnTop
SetWindow()
if DisableCriticalCheck = 1
{
	GuiControl,, NB, Ready - WARNING: CRITICAL CHECK IS OFF
}
return

node(image,loops,delay)
{
	loop, %loops%
	{
		Found := 0
		sleep %delay%
		while(Found == 0)
		{
			Found := 0
			Found := FindClick(A_ScriptDir "\pics\"image, "rNoxPlayer mc o5 Count1 n0")
			if Found >= 1
			{

			}
			else
			{
				ClickS(Safex,Safey)
				sleep 200
			}
			GuiControl,, NB, %found%
		}
	}
	RFindClick("EndTurn", "rNoxPlayer mc o5 w30000,50")
	return
}

RFindClick(x,y)
{
	local RandX, RandY
	Random, RandX, -10, 10
	Random, RandY, -10, 10
	GuiControl,, NB, %x%
	FindClick(A_ScriptDir "\pics\" x,y "Center x"RandX " y"RandY)
	return
}

Repair()
{
	global
	local ti
	tpc2 := PixelGetColorS(Gx,Gy,3)
	if (tpc2 != HPC)
	{
		ClickS(Hx,Hy)
		GuiControl,, NB, Waiting for home screen
		pc := []
		pc := [HPC,HEPC]
		WaitForPixelColor(Gx,Gy,pc)
	}
	ClickS(REx,REy)
	GuiControl,, NB, Waiting for repair screen
	pc := []
	pc := [REPC]
	WaitForPixelColor(Gx,Gy,pc)
	Sleep MiscDelay
	Loop
	{
		GuiControl,, NB, Checking HP states
		ClickS(RBx,RBy)
		Sleep MiscDelay
		tpc2 := PixelGetColorS(CCx,CCy,3)
		if (tpc2 = CCPC)
		{
			Notify("AHKCSortie", "Critical HP detected, repairing",1)
			GuiControl,, NB, Critical HP detected, repairing
			ti := BC+1
			Menu, Main, Rename, %BC%, %ti%
			BC += 1
			ClickS(CCx,CCy)
			Sleep 500
			ClickS(BBx,BBy)
			Sleep 500
			ClickS(ESx,ESy)
			Sleep 500
			ClickS(BCx,BCy)
			pc := []
			pc := [REPC]
			WaitForPixelColor(Gx,Gy,pc)
			Sleep 9000
		}
		else
		{
			Notify("AHKCSortie", "HP check completed",2)
			GuiControl,, NB, HP check completed
			return
		}
	}
}

Delay:
{
	IniRead, Busy, config.ini, Do Not Modify, Busy, 0

	if DT = 0
	{
		DT := 1
		Random, SR, MinRandomWait, MaxRandomWait
		QTS := A_TickCount
		QTL := SR
		SetTimer, NBUpdate, 2000
		tSS := MS2HMS(GetRemainingTime(QTS,QTL))
		Notify("AHKCSortie", "Starting sortie in " . tSS,1)
		Sleep SR
		goto Delay
	}
	else if (Busy = 0 and BusyS = 0)
	{
		{
			goto Sortie
		}
	}
	else
	{
		if (Busy = 1 and BusyS = 0)
		{
			GuiControl,, NB, An expedition is returning, retrying every 10 seconds
			SetTimer, NBUpdate, Off
		}
		SetTimer, Delay, 10000
	}
	return
}

RSleep(time:=600)
{
	Random, rtime, time-150, time+150
	Sleep, %rtime%
	return
}

ReceiveLogistics()
{
	; Check expedition
	RSleep(2000)
	GuiControl,, NB, Checking Logistics
	Found := 0
	while(Found == 0)
	{
		Found := 0
		Found := FindClick(A_ScriptDir "\pics\Home", "rNoxPlayer mc o5 n0")
		if Found >= 1
		{
			; at home screen w/ no logistics; return home
			GuiControl,, NB, At Home
		}
		else
		{
			Found2 := FindClick(A_ScriptDir "\pics\LogisticsReturned", "rNoxPlayer mc o5 n0")
			if Found2 >= 1
			{
				GuiControl,, NB, Logistics Received
				ClickS(Expeditionx,Expeditiony)
				RSleep()
				RFindClick("LogisticsConfirm", "rNoxPlayer mc o5 w30000,50")
				RSleep()
				ReceiveLogistics()
			}
		}
	}
	return
}

Sortie:
{
	SetTimer, NBUpdate, Off
	SetTimer, Delay, Off
	BusyS := 1
	DT := 0
	TR := 0
	GuiControl, Hide, SSB
	CheckWindow()
	if SortieInterval != -1
	{
		SetTimer, Delay, %SortieInterval%
		TR := 1
		TCS := A_TickCount
	}

	GuiControlGet, ExpeditionV
	GuiControl,, NB, %ExpeditionV%
	While (ExpeditionV == 1)
	{
		GuiControlGet, ExpeditionV
		; pc := []
		; pc := [HPC]
		; WaitForPixelColor(Gx,Gy,pc)
		RSleep(5000)
		tpc := 0
		pc := []
		pc := [HPC,ExpeditionReceived1,ExpeditionReceived2,Androidpopup0,Androidpopup1,LoginCollect,LoginCollectNotice]
		tpc := WaitForPixelColor(Homex,Homey,pc,,,5)
		if tpc = 1
		{
			GuiControl,, NB,At home [Expedition only]
		}
		else if or tpc = 2 or tpc = 3
		{
			GuiControl,, NB, Expedition Found
			ClickS(Expeditionx,Expeditiony)
			RSleep(2000)
		}
		else if tpc = 4 or tpc = 5
		{
			GuiControl,, NB, Android popup Found
			ClickS(AndroidpopupExitx,AndroidpopupExity)
		}
		else if tpc = 6
		{
			GuiControl,, NB, Login Collect Found
			ClickS(LoginCollectExitx,LoginCollectExity)
		}
		else if tpc = 7
		{
			GuiControl,, NB, Login Collec tNotice
			ClickS(LoginCollectNoticey,LoginCollectNoticey)
		}
		Else
		{
			GuiControl,, NB, Initial Event notice Found
			ClickS(Dailypopx,Dailypopy)
		}
	}

	ReceiveLogistics()

	RFindClick("Combat", "rNoxPlayer mc w30000,50")
	RSleep()
	RFindClick("Emergency", "rNoxPlayer mc o5 w30000,50")
	RSleep()
	RFindClick("4_3e", "rNoxPlayer mc o5 w30000,50")
	RSleep()
	RFindClick("battle", "rNoxPlayer mc o5 w30000,50")
	RSleep(3000)
	Found := FindClick(A_ScriptDir "\pics\Heliport", "rNoxPlayer mc o5 Count1 n0 w5000,50")
	if Found >= 1
	{

	}
	Else
	{
		GuiControl,, NB, Paused
		Pause
	}
	RFindClick("Heliport", "rNoxPlayer mc o5 w30000,50")
	RSleep()
	RFindClick("Battleok", "rNoxPlayer mc o5 w30000,50")
	RSleep()
	RFindClick("CommandPost", "rNoxPlayer mc o5 w30000,50")
	RSleep()
	RFindClick("Battleok", "rNoxPlayer mc o5 w30000,50")
	RSleep()
	RFindClick("StartCombat", "rNoxPlayer mc o5 w30000,50")
	RSleep(4500)
	RFindClick("4_3eHeliResupply", "rNoxPlayer mc o5 w30000,50")
	RSleep()
	RFindClick("Planning", "rNoxPlayer mc o5 w30000,50")
	RSleep()
	RFindClick("4_3eEnemy1", "rNoxPlayer mc o30 w30000,50")
	RSleep()
	RFindClick("4_3eEnemy2", "rNoxPlayer mc o15 w30000,50")
	RSleep()
	ControlSend, , a, Nox
	RSleep(300)
	ControlSend, , a, Nox
	RSleep()
	RFindClick("4_3eEnemy3", "rNoxPlayer mc o10 w30000,50")
	RSleep()
	RFindClick("4_3eEnemy4", "rNoxPlayer mc o25 w30000,50")
	RSleep()
	RFindClick("execute", "rNoxPlayer mc o5 w30000,50")

	Found := 0
	while(Found == 0)
	{
		Found := FindClick(A_ScriptDir "\pics\Turn00", "rNoxPlayer mc o15 n0")
		if Found >= 1
		{
			GuiControl,, NB, Last Node
			RSleep(3000)
		}
		else
		{
			GuiControl,, NB, Mid-Combat
			RSleep(1000)
		}
	}
	RFindClick("EndTurn", "rNoxPlayer mc o5 w30000,50")
	RSleep(4000)
	Found := 0
	while(Found == 0)
	{
		Found := FindClick(A_ScriptDir "\pics\Combat", "rNoxPlayer mc o15 n0")
		if Found >= 1
		{
			GuiControl,, NB, Back Home!
		}
		else
		{
			ClickS(Safex, Safey)
			GuiControl,, NB, Post-Combat
			RSleep()
		}
	}

	ReceiveLogistics()

	; Repair
	Found := 0
	Found := FindClick(A_ScriptDir "\pics\Repair", "rNoxPlayer mc o5 Count1 n0")
	if Found >= 1
	{
		RFindClick("Repair", "rNoxPlayer mc o5 w30000,50")
		RFindClick("RepairSlot", "rNoxPlayer mc o5 w30000,50")
		RFindClick("Damage", "rNoxPlayer mc o5 w30000,50")
		RFindClick("OK", "rNoxPlayer mc o5 w30000,50")
		RFindClick("RepairQuick", "rNoxPlayer mc o5 w30000,50")
		RFindClick("RepairOK", "rNoxPlayer mc o5 w30000,50")
		RFindClick("RepairReturnFaded", "rNoxPlayer mc o5 w30000,50 ")
		RFindClick("RepairReturn", "rNoxPlayer mc o5 w30000,50")
	}

	; Dismantle
	RetirementCounter := Mod(Sortiecount, 6)

	ti := RetirementCounter
	RetirementCounter += 1

	if(RetirementCounter == 5)
	{
		RFindClick("Factory", "rNoxPlayer mc o40 w30000,50")
		RFindClick("Retirement", "rNoxPlayer mc o5 w30000,50")
		loop, 2
		{
			sleep 500
			RFindClick("TdollRetirementSelect", "rNoxPlayer mc oTransN,40 w30000,50")
			sleep 500
			rti := 0
			rti2 := 5
			Loop
			{
				ClickS(TdollRetirementSlot1x+180*rti,TdollRetirementSlot1y)
				ClickS(TdollRetirementSlot1x+180*rti,TdollRetirementSlot1y+318)
				rti := rti+1
				Sleep 10

			}Until (rti > rti2)
			RFindClick("TdollRetirementOK", "rNoxPlayer mc o5 w30000,50")
		}
		RFindClick("TdollRetirementDismantle", "rNoxPlayer mc o5 w30000,50")
		Found := 0
		Found := FindClick(A_ScriptDir "\pics\TdollRetirementDismantleConfirm", "rNoxPlayer mc o5 Count1 n0 w2000,50")
		if Found >= 1
		{
			RFindClick("TdollRetirementDismantleConfirm", "rNoxPlayer mc o5 w30000,50")
		}
		sleep 2000
		RFindClick("FactoryReturn", "rNoxPlayer mc o5 w30000,50")
	}
	Sortiecount++

	GuiControl,, NB, Idle
	BusyS := 0
	GuiControl, Show, SSB
	if SortieInterval != -1
	{
		BP := 0
		SetTimer, NBUpdate, 2000
	}
	return
}

WorldF:
{
	Gui, submit,nohide
	if WorldV contains `n
	{
		StringReplace, WorldV, WorldV, `n,,All
		GuiControl,, WorldV, %WorldV%
		Send, {end}
		if (WorldV=1 or WorldV=2 or WorldV=3 or WorldV=5)
		{
			World := WorldV
			GuiControl,, NB, World set
			IniWrite,%World%,config.ini,Variables,World
		}
		else
		{
			GuiControl,, NB, Unsupported world
		}
	}
	return
}

MapF:
{
	Gui, submit,nohide
	if MapV contains `n
	{
		StringReplace, MapV, MapV, `n,,All
		GuiControl,, MapV, %MapV%
		Send, {end}
		if (MapV=1 or MapV=2 or MapV=3 or MapV=4 or MapV=5)
		{
			Map := MapV
			GuiControl,, NB, Map # set
			IniWrite,%Map%,config.ini,Variables,Map
		}
		else
		{
			GuiControl,, NB, Unsupported map #
		}
	}
	return
}

IntervalF:
{
	Gui, submit,nohide
	if IntervalV contains `n
	{
		StringReplace, IntervalV, IntervalV, `n,,All
		GuiControl,, IntervalV, %IntervalV%
		Send, {end}
		if IntervalV is integer
		{
			SortieInterval := IntervalV
			if (SortieInterval < 1000)
			{
				SortieInterval := -1
				GuiControl,, NB, Interval disabled
				SetTimer, Delay, Off
				SetTimer, NBUpdate, Off
				TR := 0
			}
			else
			{
				if TR = 1
				{
					tt := SortieInterval - A_TickCount + TCS
					if tt < 0
					{
						tt := 1000
					}
					SetTimer, Delay, %tt%
				}
				GuiControl,, NB, Interval set
			}
			IniWrite,%SortieInterval%,config.ini,Variables,SortieInterval

		}
		else
		{
			GuiControl,, NB, Invalid interval
		}
	}
	return
}

MiW:
{
	Gui, submit,nohide
	if mid contains `n
	{
		StringReplace, mid, mid, `n,,All
		GuiControl,, mid, %mid%
		Send, {end}
		MinRandomWait := mid
		IniWrite,%mid%,config.ini,Variables,MinRandomWaitS
		GuiControl,, NB, Changed minimum random delay
	}
	return
}

MaW:
{
	Gui, submit,nohide
	if mad contains `n
	{
		StringReplace, mad, mad, `n,,All
		GuiControl,, mad, %mad%
		Send, {end}
		MaxRandomWait := mad
		IniWrite,%mad%,config.ini,Variables,MaxRandomWaitS
		GuiControl,, NB, Changed max random delay
	}
	return
}

SSBF:
{
	if (Map < 1 or World < 1)
	{
		MsgBox Map or world invalid. Press enter after each field to submit.
		return
	}
	GuiControl, Hide, SSB
	BP := 1
	DT := 1
	goto Delay
	return
}

NBUpdate:
{
	if DT = 0
	{
		ts := Round((TCS + SortieInterval - A_TickCount)/60000,2)
		GuiControl,, NB, Idle - Restarting in %ts% minutes
	}
	else
	{
		tSS := MS2HMS(GetRemainingTime(QTS,QTL))
		; GuiControl,, NB, Delay - %tSS%
	}
	return
}

DN:
{
	return
}

#Include %A_ScriptDir%/Functions/Click.ahk
#Include %A_ScriptDir%/Functions/TimerUtils.ahk
#Include %A_ScriptDir%/Functions/PixelCheck.ahk
#Include %A_ScriptDir%/Functions/Pause.ahk
#Include %A_ScriptDir%/Functions/Window.ahk
#Include %A_ScriptDir%/Functions/PixelSearch.ahk
#Include %A_ScriptDir%/Functions/PixelMap.ahk
#Include %A_ScriptDir%/Functions/Notify.ahk
#Include %A_ScriptDir%/Functions/FindClick.ahk


Initialize()
{
    global
	SPGx := Array(item)
	MAPx := Array(item)
	MAPy := Array(item)
	ShipHealthy := Array(item)
	pc := Array(item)
    Q := Array()
	NC := 0
	ClickDelay := 50
	coffset := 10
}

GuiClose:
{
	WinGetPos,TWinX,TWinY
	IniWrite,%TWinX%,config.ini,Variables,LastXS
	IniWrite,%TWinY%,config.ini,Variables,LastYS
	ExitApp
}
