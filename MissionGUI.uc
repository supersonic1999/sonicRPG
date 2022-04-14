class MissionGUI extends FloatingWindow;

var automated GUIListBox MListBox;
var automated GUIButton CloseWindowButton;

var class<MissionFile> DefaultMission;
var protected array<class<MissionFile> > AvailableMissions;

function OnOpen()
{
   	local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory != none)
    {
        INVInventory.MissionGUI = self;
        INVInventory.bMissionOpen = true;
        FillContextMenu();
    }
}

function OnClose(optional bool bCancelled)
{
   	local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory != none)
    {
        INVInventory.MissionGUI = none;
        INVInventory.bMissionOpen = false;
    }
}

function FillContextMenu()
{
    local INVInventory INVInventory;
    local int i, x;
    local string MissionStatus;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());
    if(INVInventory == none)
        return;

    MListBox.List.Clear();
    for(i=0;i<AvailableMissions.Length;i++)
    {
        if(INVInventory.DataRep.CurrentMission == AvailableMissions[i])
            MissionStatus = MakeColorCode(class'mutInventorySystem'.default.YellowColor);
        else
        {
            for(x=0;x<INVInventory.DataRep.CompletedMissions.Length;x++)
            {
                if(INVInventory.DataRep.CompletedMissions[x] == AvailableMissions[i])
                {
                    MissionStatus = MakeColorCode(class'mutInventorySystem'.default.GreenColor);
                    x = INVInventory.DataRep.CompletedMissions.Length;
                }
            }
            if(MissionStatus == "")
                MissionStatus = MakeColorCode(class'mutInventorySystem'.default.RedColor);
        }
        MListBox.List.Add(MissionStatus$AvailableMissions[i].default.MissionName, none, AvailableMissions[i].default.MissionName);
        MissionStatus = "";
    }
    ContextMenu.OnSelect = ContextClick;
	ContextMenu.OnOpen = ContextMenuOpened;
	CloseWindowButton.OnClick = XButtonClicked;
}

function bool ContextMenuOpened( GUIContextMenu Menu )
{
	if(Controller == none || Controller.ActiveControl == none
    || GUIList(Controller.ActiveControl) == none)
	    return false;
	return True;
}

function ContextClick(GUIContextMenu Menu, int ClickIndex)
{
    local bool bFoundMission;
    local INVInventory INVInventory;
    local PlayerController C;

    C = PlayerOwner();
    INVInventory = class'mutInventorySystem'.static.FindINVInventory(C);
    if(Controller == none || Controller.ActiveControl == none
    || GUIList(Controller.ActiveControl) == none || INVInventory == none)
	    return;

    switch(ClickIndex)
    {
        case 0:
            INVInventory.StartNewMission(AvailableMissions[MListBox.List.LastSelected]);
            break;
        case 1:
            if(AvailableMissions[MListBox.List.LastSelected] == INVInventory.DataRep.CurrentMission)
                bFoundMission = true;
            if(bFoundMission && !INVInventory.bMissionEndOpen)
                C.ClientOpenMenu("SonicRPG45.MissionEndGUI");
            break;
        case 2:
            INVInventory.MissionItem = AvailableMissions[MListBox.List.LastSelected];
            if(!INVInventory.bMissionInfoOpen)
                C.ClientOpenMenu("SonicRPG45.MissionInfoGUI");
            break;
    }
}

defaultproperties
{
     Begin Object Class=GUIListBox Name=MissionListBox
         SelectedStyleName="BrowserListSelection"
         bVisibleWhenEmpty=True
         OnCreateComponent=MissionListBox.InternalOnCreateComponent
         StyleName="ServerBrowserGrid"
         WinTop=0.100000
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.700000
         TabOrder=11
     End Object
     MListBox=GUIListBox'sonicRPG45.MissionGUI.MissionListBox'

     Begin Object Class=GUIButton Name=CloseButton
         Caption="Close"
         WinTop=0.800000
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     CloseWindowButton=GUIButton'sonicRPG45.MissionGUI.CloseButton'

     DefaultMission=Class'sonicRPG45.Mission030F'
     AvailableMissions(0)=Class'sonicRPG45.Mission030F'
     AvailableMissions(1)=Class'sonicRPG45.Mission011F'
     AvailableMissions(2)=Class'sonicRPG45.Mission001F'
     AvailableMissions(3)=Class'sonicRPG45.Mission002F'
     AvailableMissions(4)=Class'sonicRPG45.Mission003F'
     AvailableMissions(5)=Class'sonicRPG45.Mission004F'
     AvailableMissions(6)=Class'sonicRPG45.Mission009F'
     AvailableMissions(7)=Class'sonicRPG45.Mission014F'
     AvailableMissions(8)=Class'sonicRPG45.Mission005F'
     AvailableMissions(9)=Class'sonicRPG45.Mission010F'
     AvailableMissions(10)=Class'sonicRPG45.Mission006F'
     AvailableMissions(11)=Class'sonicRPG45.Mission007F'
     AvailableMissions(12)=Class'sonicRPG45.Mission008F'
     AvailableMissions(13)=Class'sonicRPG45.Mission027F'
     AvailableMissions(14)=Class'sonicRPG45.Mission016F'
     AvailableMissions(15)=Class'sonicRPG45.Mission017F'
     AvailableMissions(16)=Class'sonicRPG45.Mission018F'
     AvailableMissions(17)=Class'sonicRPG45.Mission019F'
     AvailableMissions(18)=Class'sonicRPG45.Mission025F'
     AvailableMissions(19)=Class'sonicRPG45.Mission028F'
     AvailableMissions(20)=Class'sonicRPG45.Mission020F'
     AvailableMissions(21)=Class'sonicRPG45.Mission026F'
     AvailableMissions(22)=Class'sonicRPG45.Mission021F'
     AvailableMissions(23)=Class'sonicRPG45.Mission023F'
     AvailableMissions(24)=Class'sonicRPG45.Mission024F'
     AvailableMissions(25)=Class'sonicRPG45.Mission012F'
     AvailableMissions(26)=Class'sonicRPG45.Mission013F'
     AvailableMissions(27)=Class'sonicRPG45.Mission015F'
     AvailableMissions(28)=Class'sonicRPG45.Mission029F'
     AvailableMissions(29)=Class'sonicRPG45.Mission031F'
     AvailableMissions(30)=Class'sonicRPG45.Mission032F'
     AvailableMissions(31)=Class'sonicRPG45.Mission033F'
     WindowName="Missions"
     bResizeWidthAllowed=False
     bResizeHeightAllowed=False
     DefaultLeft=350.000000
     DefaultTop=75.000000
     DefaultWidth=0.250000
     DefaultHeight=0.250000
     bAllowedAsLast=True
     WinTop=75.000000
     WinLeft=350.000000
     WinWidth=0.250000
     WinHeight=0.250000
     Begin Object Class=GUIContextMenu Name=MissionListContextMenu
         ContextItems(0)="Start Mission"
         ContextItems(1)="End Mission"
         ContextItems(2)="Mission Information"
     End Object
     ContextMenu=GUIContextMenu'sonicRPG45.MissionGUI.MissionListContextMenu'

}
