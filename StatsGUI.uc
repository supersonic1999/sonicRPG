class StatsGUI extends FloatingWindow;

var automated GUIButton CloseWindowButton, OKButton;
var automated GUIScrollTextBox ItemDesc;
var automated GUILabel MissionPoints, CombatStats, PointsAvaliable, ClassName;
var automated GUIImage CharImage;
var automated GUIListBox MListBox;
var automated GUINumericEdit PointsToAdd;

function OnOpen()
{
    local INVInventory INVInventory;

   	INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());
   	if(INVInventory != none)
   	{
        INVInventory.bStatsGUIOpen = true;
        INVInventory.StatsGUI = self;
        CloseWindowButton.OnClick = XButtonClicked;
        OKButton.OnClick = OKClicked;
        CharImage.Image = PlayerOwner().PlayerReplicationInfo.GetPortrait();
        UpdateStats();
    }
}

function OnClose(optional bool bCancelled)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());
    if(INVInventory != none)
    {
        INVInventory.bStatsGUIOpen = false;
        INVInventory.StatsGUI = none;
    }
}

function myOnChange(GUIComponent Sender)
{
    if(Sender == none || GUIListBase(Sender) == none || GUIListBase(Sender).Index < 0
    || GUIListBase(Sender).Index >= class'mutInventorySystem'.default.Skills.length)
        return;

    ItemDesc.SetContent(class'mutInventorySystem'.default.Skills[GUIListBase(Sender).Index].Description);
}

function UpdateStats()
{
    local INVInventory INVInventory;
    local int i, SavedIndex;

   	INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

   	if(INVInventory == none || INVInventory.MutINV == none)
   	    return;

    SavedIndex = MListBox.List.Index;
    MListBox.List.OnChange = myOnChange;
    MListBox.List.TextAlign = TXTA_Left;
    MListBox.List.Clear();
    if(INVInventory.DataRep.CharClass != none)
        ClassName.Caption = ("Class:" @ INVInventory.DataRep.CharClass.default.ClassName);
    MissionPoints.Caption = ("Mission Points:" @ INVInventory.GetMissionPoints());
    PointsAvaliable.Caption = ("Points Avaliable:" @ INVInventory.MutINV.static.GetPointsAvaliable(INVInventory));
    CombatStats.Caption = ("Combat Lvl:" @ INVInventory.DataRep.CombatLevel @ "-" @ int(INVInventory.DataRep.CombatXP) $ "/"
                         $ INVInventory.MutINV.GetCurrentXP(INVInventory.DataRep.CombatLevel));

    for(i=0;i<INVInventory.MutINV.Skills.Length;i++)
        MListBox.List.Add(INVInventory.MutINV.Skills[i].SkillName @ "-" @ INVInventory.DataRep.SkillLevel[i]);
    MListBox.List.SetIndex(SavedIndex);
}

function bool OKClicked(GUIComponent Sender)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory == none || MListBox == none || MListBox.MyList == none || MListBox.MyList.Index < 0
    || MListBox.MyList.Index >= class'mutInventorySystem'.default.Skills.length)
        return false;

    INVInventory.AddSkillPoints(int(PointsToAdd.Value), MListBox.MyList.Index);
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
     CloseWindowButton=GUIButton'sonicRPG45.StatsGUI.CloseButton'

     Begin Object Class=GUIButton Name=ok
         Caption="OK"
         WinTop=0.350000
         WinLeft=0.300000
         WinWidth=0.100000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnKeyEvent=ok.InternalOnKeyEvent
     End Object
     OkButton=GUIButton'sonicRPG45.StatsGUI.ok'

     Begin Object Class=GUIScrollTextBox Name=ItemDescription
         bNoTeletype=True
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=ItemDescription.InternalOnCreateComponent
         WinTop=0.700000
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.150000
         bTabStop=False
         bNeverFocus=True
     End Object
     ItemDesc=GUIScrollTextBox'sonicRPG45.StatsGUI.ItemDescription'

     Begin Object Class=GUILabel Name=MissionP
         Caption="Mission Points: 0"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.050000
         WinLeft=0.050000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     MissionPoints=GUILabel'sonicRPG45.StatsGUI.MissionP'

     Begin Object Class=GUILabel Name=CombatStat
         Caption="Combat Level: 0"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.100000
         WinLeft=0.050000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     CombatStats=GUILabel'sonicRPG45.StatsGUI.CombatStat'

     Begin Object Class=GUILabel Name=PointsAval
         Caption="Points Avaliable: 0"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.150000
         WinLeft=0.050000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     PointsAvaliable=GUILabel'sonicRPG45.StatsGUI.PointsAval'

     Begin Object Class=GUILabel Name=cname
         Caption="Class: none"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.200000
         WinLeft=0.050000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     ClassName=GUILabel'sonicRPG45.StatsGUI.cname'

     Begin Object Class=GUIImage Name=CImage
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.050000
         WinLeft=0.750000
         WinWidth=0.200000
         WinHeight=0.400000
     End Object
     CharImage=GUIImage'sonicRPG45.StatsGUI.CImage'

     Begin Object Class=GUIListBox Name=MissionListBox
         SelectedStyleName="BrowserListSelection"
         bVisibleWhenEmpty=True
         OnCreateComponent=MissionListBox.InternalOnCreateComponent
         StyleName="ServerBrowserGrid"
         WinTop=0.450000
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.200000
         TabOrder=11
     End Object
     MListBox=GUIListBox'sonicRPG45.StatsGUI.MissionListBox'

     Begin Object Class=GUINumericEdit Name=PointsAdd
         Value="1"
         MinValue=1
         MaxValue=999
         WinTop=0.350000
         WinLeft=0.050000
         WinWidth=0.250000
         WinHeight=0.100000
         OnDeActivate=PointsAdd.ValidateValue
     End Object
     PointsToAdd=GUINumericEdit'sonicRPG45.StatsGUI.PointsAdd'

     WindowName="Stats"
     bResizeWidthAllowed=False
     bResizeHeightAllowed=False
     DefaultLeft=0.250000
     DefaultTop=0.000000
     DefaultWidth=0.350000
     DefaultHeight=0.500000
     bAllowedAsLast=True
     WinTop=0.000000
     WinLeft=0.250000
     WinWidth=0.350000
}
