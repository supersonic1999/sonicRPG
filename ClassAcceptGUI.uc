class ClassAcceptGUI extends FloatingWindow;

var automated GUIButton DeclineButton, AcceptButton;
var automated GUILabel AcceptStringLabel;
var byte SelectedClass;

function OnOpen()
{
    DeclineButton.OnClick = DeclineButtonClick;
    AcceptButton.OnClick = AcceptButtonClick;
}

function bool DeclineButtonClick(GUIComponent Sender)
{
    XButtonClicked(Sender);
    return true;
}

function bool AcceptButtonClick(GUIComponent Sender)
{
    local INVInventory INVInventory;

   	INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());
    if(INVInventory == none || SelectedClass < 0
    || SelectedClass >= class'mutInventorySystem'.default.ClassesAvailable.length)
        return false;

    INVInventory.SetClass(class'mutInventorySystem'.default.ClassesAvailable[SelectedClass]);
    XButtonClicked(Sender);
    return true;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=DButton
         Caption="No"
         WinTop=0.750000
         WinLeft=0.525000
         WinWidth=0.425000
         WinHeight=0.150000
         bBoundToParent=True
         bScaleToParent=True
         OnKeyEvent=DButton.InternalOnKeyEvent
     End Object
     DeclineButton=GUIButton'sonicRPG45.ClassAcceptGUI.DButton'

     Begin Object Class=GUIButton Name=AButton
         Caption="Yes"
         WinTop=0.750000
         WinLeft=0.050000
         WinWidth=0.425000
         WinHeight=0.150000
         bBoundToParent=True
         bScaleToParent=True
         OnKeyEvent=AButton.InternalOnKeyEvent
     End Object
     AcceptButton=GUIButton'sonicRPG45.ClassAcceptGUI.AButton'

     Begin Object Class=GUILabel Name=AStringLabel
         Caption="Are you sure you want to pick this class? You wont be able to change class after you accept."
         TextColor=(B=255,G=255,R=255)
         bMultiLine=True
         WinTop=0.100000
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.650000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     AcceptStringLabel=GUILabel'sonicRPG45.ClassAcceptGUI.AStringLabel'

     WindowName="Are You Sure?"
     bResizeWidthAllowed=False
     bResizeHeightAllowed=False
     bMoveAllowed=False
     DefaultLeft=0.250000
     DefaultTop=0.000000
     DefaultWidth=0.250000
     DefaultHeight=0.250000
     bAllowedAsLast=True
     WinLeft=0.375000
     WinWidth=0.250000
     WinHeight=0.250000
}
