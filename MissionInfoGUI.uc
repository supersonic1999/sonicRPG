class MissionInfoGUI extends FloatingWindow;

var protected string Text;

var automated GUIButton CloseWindowButton, PlayButton;
var automated GUIScrollTextBox ItemDesc;
var automated GUILabel MissionDifficulty;

function OnOpen()
{
    local INVInventory INVInventory;

   	INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());
   	if(INVInventory != none)
   	{
        INVInventory.bMissionInfoOpen = true;
        INVInventory.MissionInfoGUI = self;
        CloseWindowButton.OnClick = XButtonClicked;
        PlayButton.OnClick = PlayClicked;
        UpdateDescription();
    }
}

function OnClose(optional bool bCancelled)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());
    if(INVInventory != none)
    {
        INVInventory.bMissionInfoOpen = false;
        INVInventory.MissionInfoGUI = none;
    }
}

function UpdateDescription()
{
    local PlayerController C;
    local INVInventory INVInventory;

   	INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());
   	if(INVInventory == none)
   	    return;

    C = PlayerOwner();
    MissionDifficulty.Caption = ("Difficulty:" @ INVInventory.MissionItem.default.MissionDifficulty);
    Text = INVInventory.MissionItem.static.GetDescription(C);
    ItemDesc.SetContent(Text);
}

function bool PlayClicked(GUIComponent Sender)
{
    PlayerOwner().TextToSpeech(Text, 255);
    return true;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=CloseButton
         Caption="Close"
         WinTop=0.850000
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     CloseWindowButton=GUIButton'sonicRPG45.MissionInfoGUI.CloseButton'

     Begin Object Class=GUIButton Name=PButton
         Caption="Play"
         WinTop=0.050000
         WinLeft=0.850000
         WinWidth=0.100000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnKeyEvent=PButton.InternalOnKeyEvent
     End Object
     PlayButton=GUIButton'sonicRPG45.MissionInfoGUI.PButton'

     Begin Object Class=GUIScrollTextBox Name=ItemDescription
         bNoTeletype=True
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=ItemDescription.InternalOnCreateComponent
         WinTop=0.150000
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.700000
         bTabStop=False
         bNeverFocus=True
     End Object
     ItemDesc=GUIScrollTextBox'sonicRPG45.MissionInfoGUI.ItemDescription'

     Begin Object Class=GUILabel Name=MissionD
         Caption="Difficulty: Unknown"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.050000
         WinLeft=0.050000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     MissionDifficulty=GUILabel'sonicRPG45.MissionInfoGUI.MissionD'

     WindowName="Mission Information"
     bResizeWidthAllowed=False
     bResizeHeightAllowed=False
     DefaultLeft=0.250000
     DefaultTop=0.000000
     DefaultWidth=0.500000
     DefaultHeight=0.500000
     bAllowedAsLast=True
     WinTop=0.000000
     WinLeft=0.250000
     WinWidth=0.500000
}
