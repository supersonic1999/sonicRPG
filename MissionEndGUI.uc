class MissionEndGUI extends FloatingWindow;

var automated GUIButton YesButton, NoButton;

function OnOpen()
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());
	if(INVInventory != None)
        INVInventory.bMissionEndOpen = true;
}

function OnClose(optional bool bCancelled)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());
    if(INVInventory != none)
        INVInventory.bMissionEndOpen = false;
}

function bool YesClicked(GUIComponent Sender)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());
    if(INVInventory != none)
        INVInventory.EndCurrentMission();
    XButtonClicked(Sender);
    return true;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=Yes
         Caption="Yes"
         WinTop=0.475000
         WinLeft=0.100000
         WinWidth=0.400000
         WinHeight=0.250000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=MissionEndGUI.YesClicked
         OnKeyEvent=Yes.InternalOnKeyEvent
     End Object
     YesButton=GUIButton'sonicRPG45.MissionEndGUI.Yes'

     Begin Object Class=GUIButton Name=NO
         Caption="No"
         WinTop=0.475000
         WinLeft=0.500000
         WinWidth=0.400000
         WinHeight=0.250000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=MissionEndGUI.XButtonClicked
         OnKeyEvent=NO.InternalOnKeyEvent
     End Object
     NoButton=GUIButton'sonicRPG45.MissionEndGUI.NO'

     WindowName="End Mission?"
     bResizeWidthAllowed=False
     bResizeHeightAllowed=False
     DefaultLeft=0.350000
     DefaultTop=0.450000
     DefaultWidth=0.150000
     DefaultHeight=0.050000
     bAllowedAsLast=True
     WinTop=0.500000
     WinLeft=0.500000
     WinWidth=0.150000
     WinHeight=0.050000
}
