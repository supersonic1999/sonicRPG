class InformationGUI extends FloatingWindow;

var automated GUIButton CloseWindowButton;
var automated GUIImage ItemScreenShot;
var automated GUIScrollTextBox ItemDesc, ItemInfomation;

function OnOpen()
{
    local INVInventory INVInventory;
    local PlayerController C;

    C = PlayerOwner();
    if(C != none)
        INVInventory = class'mutInventorySystem'.static.FindINVInventory(C);
    if(INVInventory != none)
    {
        INVInventory.bInformationOpen = true;
        INVInventory.Information = self;

        ItemScreenShot.Image = INVInventory.InfoClass.default.Image;
        t_WindowTitle.SetCaption(INVInventory.InfoClass.static.GetInvItemName(C));
        ItemInfomation.SetContent(INVInventory.InfoClass.static.GetItemInformation(C));
        ItemDesc.SetContent(INVInventory.InfoClass.static.GetDescription(C));
    }
}

function OnClose(optional bool bCancelled)
{
    local INVInventory INVInventory;

    INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());

    if(INVInventory != none)
    {
        INVInventory.bInformationOpen = false;
        INVInventory.Information = none;
    }
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
         OnClick=InformationGUI.XButtonClicked
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     CloseWindowButton=GUIButton'sonicRPG45.InformationGUI.CloseButton'

     Begin Object Class=GUIImage Name=Screenshot
         ImageStyle=ISTY_Scaled
         BorderOffsets(0)=50.000000
         BorderOffsets(1)=50.000000
         BorderOffsets(2)=50.000000
         BorderOffsets(3)=50.000000
         WinTop=0.100000
         WinLeft=0.050000
         WinWidth=0.250000
         WinHeight=0.250000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     ItemScreenShot=GUIImage'sonicRPG45.InformationGUI.Screenshot'

     Begin Object Class=GUIScrollTextBox Name=ItemDescription
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=ItemDescription.InternalOnCreateComponent
         WinTop=0.400000
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.400000
         bTabStop=False
         bNeverFocus=True
     End Object
     ItemDesc=GUIScrollTextBox'sonicRPG45.InformationGUI.ItemDescription'

     Begin Object Class=GUIScrollTextBox Name=ItemInfo
         bNoTeletype=True
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=ItemInfo.InternalOnCreateComponent
         WinTop=0.100000
         WinLeft=0.350000
         WinWidth=0.600000
         WinHeight=0.250000
         bTabStop=False
         bNeverFocus=True
     End Object
     ItemInfomation=GUIScrollTextBox'sonicRPG45.InformationGUI.ItemInfo'

     WindowName="Item Information"
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
