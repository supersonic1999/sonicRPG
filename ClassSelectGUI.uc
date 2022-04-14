class ClassSelectGUI extends FloatingWindow;

var automated GUIButton AcceptButton, DeclineButton;
var automated GUIScrollTextBox ItemDesc;
var automated GUIImage CharImage;
var automated GUIListBox MListBox;

var material EmptyClassImage;
var protected bool bIsntFirstChange;

function OnOpen()
{
    local INVInventory INVInventory;
    local int i;

   	INVInventory = class'mutInventorySystem'.static.FindINVInventory(PlayerOwner());
   	if(INVInventory != none)
   	{
        if(INVInventory.DataRep.CharClass != none)
        {
            XButtonClicked(none);
            return;
        }
        AcceptButton.OnClick = AcceptButtonClicked;
        DeclineButton.OnClick = DeclineButtonClicked;
        CharImage.Image = EmptyClassImage;
        MListBox.List.OnChange = myOnChange;
        MListBox.List.TextAlign = TXTA_Left;
        for(i=0;i<class'mutInventorySystem'.default.ClassesAvailable.Length;i++)
            MListBox.List.Add(class'mutInventorySystem'.default.ClassesAvailable[i].default.ClassName);
    }
}

function myOnChange(GUIComponent Sender)
{
    if(Sender == none || GUIListBase(Sender) == none || GUIListBase(Sender).Index < 0
    || GUIListBase(Sender).Index >= class'mutInventorySystem'.default.ClassesAvailable.length)
        return;
    else if(!bIsntFirstChange)
    {
        MListBox.List.Index = 255;
        bIsntFirstChange = true;
        ItemDesc.SetContent("No class selected.|Please select one to get its information.");
    }
    else
    {
        ItemDesc.SetContent(class'mutInventorySystem'.default.ClassesAvailable[GUIListBase(Sender).Index].default.ClassDescription);
        if(GUIListBase(Sender).Index >= 0
        && class'mutInventorySystem'.default.ClassesAvailable.Length > GUIListBase(Sender).Index
        && class'mutInventorySystem'.default.ClassesAvailable[GUIListBase(Sender).Index] != none
        && class'mutInventorySystem'.default.ClassesAvailable[GUIListBase(Sender).Index].default.ClassPicture != none)
            CharImage.Image = class'mutInventorySystem'.default.ClassesAvailable[GUIListBase(Sender).Index].default.ClassPicture;
        else CharImage.Image = EmptyClassImage;
    }
}

function bool DeclineButtonClicked(GUIComponent Sender)
{
    XButtonClicked(Sender);
    return true;
}

function bool AcceptButtonClicked(GUIComponent Sender)
{
    if(Controller != none && MListBox.List.Index != 255)
    {
        Controller.OpenMenu("SonicRPG45.ClassAcceptGUI");
        ClassAcceptGUI(Controller.ActivePage).SelectedClass = MListBox.List.Index;
        Controller.RemoveMenu(self);
        return true;
    }
    return false;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=AButton
         Caption="Accept"
         WinTop=0.750000
         WinLeft=0.600000
         WinWidth=0.150000
         WinHeight=0.150000
         bBoundToParent=True
         bScaleToParent=True
         OnKeyEvent=AButton.InternalOnKeyEvent
     End Object
     AcceptButton=GUIButton'sonicRPG45.ClassSelectGUI.AButton'

     Begin Object Class=GUIButton Name=DButton
         Caption="Decline"
         WinTop=0.750000
         WinLeft=0.800000
         WinWidth=0.150000
         WinHeight=0.150000
         bBoundToParent=True
         bScaleToParent=True
         OnKeyEvent=DButton.InternalOnKeyEvent
     End Object
     DeclineButton=GUIButton'sonicRPG45.ClassSelectGUI.DButton'

     Begin Object Class=GUIScrollTextBox Name=ItemDescription
         bNoTeletype=True
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=ItemDescription.InternalOnCreateComponent
         WinTop=0.500000
         WinLeft=0.050000
         WinWidth=0.450000
         WinHeight=0.400000
         bTabStop=False
         bNeverFocus=True
     End Object
     ItemDesc=GUIScrollTextBox'sonicRPG45.ClassSelectGUI.ItemDescription'

     Begin Object Class=GUIImage Name=CImage
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.100000
         WinLeft=0.600000
         WinWidth=0.350000
         WinHeight=0.600000
     End Object
     CharImage=GUIImage'sonicRPG45.ClassSelectGUI.CImage'

     Begin Object Class=GUIListBox Name=MissionListBox
         SelectedStyleName="BrowserListSelection"
         bVisibleWhenEmpty=True
         OnCreateComponent=MissionListBox.InternalOnCreateComponent
         StyleName="ServerBrowserGrid"
         WinTop=0.100000
         WinLeft=0.050000
         WinWidth=0.450000
         WinHeight=0.400000
         TabOrder=11
     End Object
     MListBox=GUIListBox'sonicRPG45.ClassSelectGUI.MissionListBox'

     EmptyClassImage=Texture'PlayerPictures.cDefault'
     WindowName="Class Selection"
     bResizeWidthAllowed=False
     bResizeHeightAllowed=False
     bMoveAllowed=False
     DefaultLeft=0.250000
     DefaultTop=0.250000
     DefaultWidth=0.500000
     DefaultHeight=0.250000
     bAllowedAsLast=True
     WinLeft=0.250000
     WinWidth=0.500000
     WinHeight=0.250000
}
